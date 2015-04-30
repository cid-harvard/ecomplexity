****************************************************************************************************************
* calculates Mcp matrix
****************************************************************************************************************

cap program drop calculate_mcp
program define calculate_mcp
 
version 10

syntax [varlist  ]  [, i(varlist) p(varlist) t(varlist) rca(real 1 ) rca2(real 999999 ) herf(real 999999)]
tokenize "`varlist'"
local val = "`1'"

/// Droping variables that would be output-variables.
cap drop _fillin
cap drop _merge

sort `t' `i' `p'

cap levelsof `t', local(year_levels)


quietly levelsof `i', local(Ni)
quietly levelsof `p', local(Np)
quietly levelsof `t', local(Nt)
global Nnc: word count `Ni' 
global Nnp: word count `Np'
global Nnt: word count `Nt'


display "________________________________________________________________________________________________"
display "Number of periods in sample             : $Nnt"
display "Number of locations in sample           : $Nnc"
display "Number of products/industries in sample : $Nnp"
display "Calculations for time period            :", _c

tempvar  touse

quietly{
	// Generate the variables the will store the output of the matrix calculations
	gen byte mcp = .
	tempfile newfile1 newfile2 newfile3 
	save "`newfile1'", replace
	drop in 1/l
	save "`newfile2'", replace emptyok
}

// Start the loop tha would calculate variables year by year. 
foreach y of local year_levels{
		display "`y'", _c
		cap use "`newfile1'", clear
		cap keep if `t'==`y'
		cap fillin  `i' `p'
		cap replace `val'=0 if _fillin==1
		cap replace `t' = `y' if _fillin==1
		cap drop _fillin
	
        cap gen byte `touse' = (`val'!=.)
		quietly levelsof `i' if `touse'==1, local(LOCATION)
		quietly levelsof `p' if `touse'==1, local(PRODUCT)
			
		global Nc: word count `LOCATION' 
		global Np: word count `PRODUCT'

		/// matrix calculations 		
		mata Ncx=strtoreal(st_global("Nc"))
		mata Npx=strtoreal(st_global("Np"))
	
	    mata exp_long=st_data(.,"`val'", "`touse'") // loads values of export/production into the matrix in long format 
		mata exp_cp = rowshape(exp_long,Ncx)  // reshape the data into a square matrix
		
		// calculations of rca
		// calculations of rca
		mata exp_tot = sum(exp_cp)		
		mata exp_p= J(Ncx,Ncx,1) * exp_cp 	
		mata exp_c = exp_cp * J(Npx,Npx,1)		 						
		mata RCA = (exp_cp:/exp_c):/(exp_p:/exp_tot) 
		
		// I'll first calculate M1 which uses RCA1 (with all products)
		mata M1=(RCA:>`rca')  // M1 = RCA>1.0
		
		mata M2 = J(Ncx, Npx, 0)
		mata M3 = J(Ncx, Npx, 0)
		
		if `rca' != 999999 & `rca2' != 999999 {
		
			mata M2=(RCA:>`rca2') // I Identify which are the products with extremely high RCA, ie above rca2
									 // M2 = RCA>100.0
			mata exp2_cp = exp_cp - (exp_cp:*M2) // new value matrix without high-RCA products
	
			mata exp_tot2 = sum(exp2_cp)		
			mata exp_p2= J(Ncx,Ncx,1) * exp2_cp 	
			mata exp_c2 = exp2_cp * J(Npx,Npx,1)
			mata RCA2 = (exp2_cp:/exp_c2):/(exp_p2:/exp_tot2) // calculate RCA2, using the export matrix 
														   // excluding high RCA products
			// RCA = calculated using all products | RCA2 = calculated after removing extremely high RCA products
			mata M2=(RCA2:>`rca') // Overwrite M2 asigning a 1 to those cells where RCA2 is higher than the 
									 // rca (ie. RCA2>1)
		}

		if `herf' != 999999 {
			// calculating Herfindahl-Hirschman (HH) Index for each product
			// For each product, HH is defined as sum of the squares of the shares of each country.
			mata exp_p= J(Ncx,Ncx,1) * exp_cp
			mata share_p = exp_cp:/exp_p 			 						
			mata HH = (J(Ncx,Ncx,1) * (share_p :* share_p)):*J(Ncx, Npx,`herf')		
			// We will assume that if a country provides 0.5*HH of the product, it effectively produces it.
			mata M3 = share_p :> HH
		}
		
		
		mata M = M1+M2+M3 
		mata M = (M:>0) // M is a [0,1] matrix with 1 if either RCA was above the threshold
					  // ie. M=1 if either RCA>1 or RCA2>1 
					  

		mata m_long=vec(M') // rca
		mata st_store(.,"mcp", "`touse'", m_long)
		
        cap mata mata clear // erases the matrices from the memory
        
                quietly{      // saves the results for the year, opens the file were we store the data
        			          // and 
				save "`newfile3'", replace
				use  "`newfile2'", clear
				append using "`newfile3'"
				save "`newfile2'", replace
		}
}

display " "
display "________________________________________________________________________________________________"
// setting the right order for the complexity variables - using 
// the ci and clp inputs from the syntax

label var mcp "RCA>`rca'"

end 

// complexity year iso prod exp, th(0.8) 

// tab year
