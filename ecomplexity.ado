*----------------------------------------------------------------------------------------
cap program drop ecomplexity
program define ecomplexity
*----------------------------------------------------------------------------------------

// net install ecomplexity, from("https://raw.githubusercontent.com/cid-harvard/ecomplexity/master/") force

version 10
syntax varlist [if/], i(varlist) p(varlist) [t(varlist) pop(varlist) rca(real -1) rpop(real -1) knn(real -1) cont leaveout im(varlist) asym bi piet]


*----------------------------------------------------------------------
marksample touse
tokenize "`varlist'"
local val = "`1'"
global error_code = 0
local dropped_zero = 0

*----------------------------------------------------------------------
// Drop variables that can confuse the output
*----------------------------------------------------------------------
local errorexistenvar=0
local create_variables M RCA RPOP rca rpop mcp density eci pci coi cog kc0 kp0 diversity ubiquity _merge _fillin id_i id_p piet_c piet_p
foreach var in `create_variables' {
	cap drop `var'
	*noi di "`var'" _rc
	if `errorexistenvar'==0 & _rc==0 {
		noi display "________________________________________________________________________________________________"
		noi di "Warning!! At least one output variable name was present in the dataset."
		noi di "Will delete those variables from memory!!"
		noi display "________________________________________________________________________________________________"
		local errorexistenvar=1
	}
}

if ("`pop'" ~= "" & `rpop' ~= -1) {
	local calculate_rpop 1	
}
else if `rpop' ~= -1 {
	noi di "Warning: You specified an rpop threshold but did not provide pop variable!!!"
	exit
}
else {
	local calculate_rpop 0
}

if `calculate_rpop' == 1 & `rca' != -1 & "`cont'"~="" {
	noi di "When using continous option, please only use just one of RCA or RPOP!!!"
	exit
}
			
if "`t'"=="" {
	local t_present 0
	tempvar t
	qui gen byte `t' = 1
}
else {
	local t_present 1
}
*----------------------------------------------------------------------


*----------------------------------------------------------------------
* M matrix provided? Detecting binary dataset
*----------------------------------------------------------------------

// if main variable is already in a binary format, 
// the program will asume it corresponds to the Mcp Matrix
qui sum `val'
local l1 = r(min)
local l2 = r(max)
if (`l1'==0 & `l2'==1)  | "`bi'"~="" {
	local l0 = 1
	noi di “ “   
	noi di "Binary variable detected"
}
else {
	local l0 = 0 
}



*----------------------------------------------------------------------

sort `t' `i' `p'

cap levelsof `t', local(year_levels)

quietly levelsof `t', local(Nt)
global Nnt: word count `Nt'
display " "
display "Creates economic complexity variables"
display "________________________________________________________________________________________________"
if `t_present' == 1  & $Nnt > 1 { 
	display "Number of periods in sample             : $Nnt"
	display "Calculations for time period            :", _c
}

quietly {
	cap tempfile newfile1 newfile2 newfile3 newfile4
	save "`newfile1'", replace
	drop in 1/l
	save "`newfile2'", replace emptyok
	save "`newfile4'", replace emptyok
}

//============================================================================================================
foreach y of local year_levels{
		if `t_present' == 1  & $Nnt > 1 { 
			display "`y'", _c
		}
		cap use "`newfile1'", clear
		cap keep if `t'==`y'
		
		*------------------------------------------------
		quietly{
			count if `touse' == 0
			local foundzeroes = r(N)		
			if `foundzeroes' > 0 {
				local dropped_zero = 1
				preserve
				keep if `touse' == 0
				save "`newfile3'", emptyok replace
				use  "`newfile4'", clear
				append using "`newfile3'"
				save "`newfile4'", replace
				restore
				drop if `touse' == 0
			}
		}
		*------------------------------------------------
		
		if (`calculate_rpop' == 1) {
			local 1	
			quietly{
				tempvar temppop
				egen `temppop' = mean(`pop'), by(`i')
				replace `pop' = `temppop'
				drop `temppop'
			
				count if `pop' == . | `pop' <= 0
				local foundzeroes = r(N)
				
				if `foundzeroes' > 0 {
					local dropped_zero = 1
					preserve
					keep if `pop' == . | `pop' <= 0
					save "`newfile3'", emptyok replace
					use  "`newfile4'", clear
					append using "`newfile3'"
					save "`newfile4'", replace
					restore
					drop if `pop' == . | `pop' <= 0
				}
			}
		}
		*------------------------------------------------
		
		
		*------------------------------------------------
		* Checks data 
		*------------------------------------------------
		quietly{
			tempvar sum_i sum_p
			foreach j in i p {
				egen `sum_`j'' = total(`val'), by(``j'')
				
				count if `sum_`j'' == . | `sum_`j'' <= 0
				local foundzeroes = r(N)
				
				if `foundzeroes' > 0 {
					local dropped_zero = 1
					preserve
					keep if `sum_`j'' == . | `sum_`j'' <= 0
					save "`newfile3'", emptyok replace
					use  "`newfile4'", clear
					append using "`newfile3'"
					save "`newfile4'", replace
					restore
					drop if `sum_`j'' == . | `sum_`j'' <= 0
				}
				
				drop `sum_`j''
			}
		}
		
		*------------------------------------------------
		* Loads data into Mata matrices 
		*------------------------------------------------
		load_export_mata `t' `i' `p' `val' `touse'
		if $error_code == 1 exit // error checking
		*------------------------------------------------
		
		// Inmediate Mcp
		if `l0'==1 {
			mata M = exp_cp
		}
		
		*------------------------------------------------
		* Calculate RCA and Rpop
		*------------------------------------------------
		// calculate RCA case
		if `calculate_rpop' == 0 & `l0'==0 {
			if `rca' == -1 {
				local rca 1
			}
			complexity_rca
			mata M = (RCA:>`rca')
		}
		
		// calculate Rpop case
		else if `calculate_rpop' == 1 & `rca' == -1 & `l0'==0 {
			load_population_mata `i' `pop' `touse'
			complexity_rpop
			mata M = (RPOP:>`rpop')
		}
		
		if $error_code == 1 exit		
		
		// combination of the two (RCA AND Rpop)
		else if `calculate_rpop' == 1 & `rca' != -1 & `l0'==0 {
			load_population_mata `i' `pop' `touse'
			complexity_rca
			complexity_rpop
			mata M1 = (RCA:>`rca')
			mata M2 = (RPOP:>`rpop')
			mata M = M1 + M2 
			mata M = (M:>0)
		}
		
		
		*------------------------------------------------
		
		
		//----------------------------------------------------------------------------
		// 			Calculate proximity and density
		//----------------------------------------------------------------------------
		*noi di "continuous is `cont'"
		*noi di "No leaveout is `leaveout'"
		if `calculate_rpop' == 0 & "`cont'"~="" {
			*noi display "	: Continuous"
			proxcontinous, levels(RCA)
			calculate_density, knn(`knn') `cont' `leaveout' levels(RCA)
		}
		else if `calculate_rpop' == 1 & "`cont'"~="" {
			*noi display "	: Continuous"
			proxcontinous, levels(RPOP)
			calculate_density, knn(`knn') `cont' `leaveout'  levels(RPOP)
		}	
		else {
			*noi display "	: Discrete"
			proxdiscrete, `asym'
			calculate_density, knn(`knn')
		}
		//----------------------------------------------------------------------------
		
	
		*===================================
		ecipci /* calculates eigenvector */
		*===================================
		
		*============================================================
		coicog	 /* calculates complexity outlook uindex and gain */
		*============================================================
		
		if "`piet'"~="" {
			pietronero
		}
			
		*------------------------------------------------------------------------------
		* Turns matrices into stata dataset shape
		*------------------------------------------------------------------------------
		if `rca' != -1 {
			mata tostata = colshape(RCA,1)
			qui mata newvar_row = st_addvar("double", "rca")
  			qui mata st_store(.,newvar_row,"`touse'",tostata)
		}
		if `calculate_rpop' == 1 {
			mata tostata = colshape(RPOP,1)
			qui mata newvar_row = st_addvar("double", "rpop")
  			qui mata st_store(.,newvar_row,"`touse'",tostata)
		}			
		foreach var in M density kc kp kc0 kp0 coi cog { 
   			mata tostata = colshape(`var',1)
   			qui mata newvar_row = st_addvar("double", "`var'")
  			qui mata st_store(.,newvar_row,"`touse'",tostata)
		}
		
		if "`piet'"~="" {
			foreach var in piet_c piet_p { 
				mata tostata = colshape(`var',1)
				qui mata newvar_row = st_addvar("double", "`var'")
				qui mata st_store(.,newvar_row,"`touse'",tostata)
			}
		}
		
		*------------------------------------------------------------------------------
		
		quietly{      
		 	rename kc eci
			rename kp pci
			rename kc0 diversity
			rename kp0 ubiquity
			drop id_i
			drop id_p
			
			*------------------------------------------------------------------------------
			// Normalization: mean of zero and st dev of 1
			*------------------------------------------------------------------------------
			// ECI
			sum eci
			replace eci = (eci-r(mean))/r(sd)
			replace pci = (pci-r(mean))/r(sd)
			replace cog = cog/r(sd)
			// OPPVAL
			sum coi
			replace coi = (coi-r(mean))/r(sd)
			*------------------------------------------------------------------------------
			
			
			*------------------------------------------------------------------------------
		 	// saves the results for the year, opens the file were we store the data 
			*------------------------------------------------------------------------------
			save "`newfile3'", replace
			use  "`newfile2'", clear
			append using "`newfile3'"
			save "`newfile2'", replace
		}
}
//============================================================================================================

if `dropped_zero' == 1 append using "`newfile4'"
qui drop if M==. 
if `l0'==1 {
	cap drop M // If the Mcp matrix was provided by user, there is no need to report it in new dataset
}

*------------------------------------------------------------------------------
* Labeling
*------------------------------------------------------------------------------
cap label var year "Year"
cap label var rca "Revealed Comparative Advantage (RCA)"
cap label var rpop "Revealed per capita Advantage (RPOP)"
cap label var density "Product Density "
cap label var coi "Complexity Outlook Index"
cap label var cog "Opportunity Gain"
cap label var eci "Economic Complexity Index" 
cap label var pci "Product Complexity Index"
cap label var diversity "Country Diversity"
cap label var ubiquity "Product Ubiquity"
cap label var piet_c "Country Measure of Pietronero"
cap label var piet_p "Product Measure of Pietronero"
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* Showing options used in the calculations
*------------------------------------------------------------------------------
di " "
* Options for RCA and Rpop and M
if `l0' == 1 {
	display " : Using  M matrix provided by user"
}

if `calculate_rpop' == 0 & `l0' == 0 {
	display " : Using  RCA with threshold of `rca'"
}
		
else if `calculate_rpop' == 1 & `rca' == -1 & `l0' == 0 {
	display " : Using Rpop with threshold of `rpop'" 	
}		
		
else if `calculate_rpop' == 1 & `rca' != -1 & `l0' == 0 {
	display " : Using combination of RCA>=`rca' and Rpop>=`rpop'"
}
* Options for Proximity matrices
if "`cont'"~="" {
	  display " : Using Continuous", _c
}	
else {
	  display " : Using Discrete", _c
}

if "`asym'"~="" {
	  display "and Asymmetric Proximity"

}	
else {
	  display "and Symmetric Proximity"

}
*------------------------------------------------------------------------------


*------------------------------------------------------------------------------
* The End
*------------------------------------------------------------------------------		
display "________________________________________________________________________________________________"
end
*------------------------------------------------------------------------------
