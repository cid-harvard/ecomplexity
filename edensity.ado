*

cap program drop edensity
program define edensity

version 10

syntax varlist [if/], i(varlist) p(varlist) [t(varlist) pop(varlist) rca(real -1) rpop(real -1) knn(real -1) cont im(varlist) asym]
marksample touse

display "Calculates Density"

tokenize "`varlist'"
local val = "`1'"

/*
1- Convert data into Mata (exp + scale)
2- RCA, RPOP
3- MCP
4- Proximity (cont or discrete, symmteric or assymetric) 5' Output proximity into a file
5- Density (all or knn)
6- Complexity Outlook & Complexity Outlook Gain
*/

global error_code = 0
local dropped_zero = 0

// Drop Variables that can confuse the output
local errorexistenvar=0
local create_variables M RCA rca rpop mcp density eci pci oppval oppgain _fillin id_i id_p
foreach var in `create_variables' {
	cap drop `var'
	*noi di "`var'" _rc
	if `errorexistenvar'==0 & _rc==0 {
		noi display "________________________________________________________________________________________________"
		noi di "Warning!! At least one output variable name was present in the dataset."
		noi di "Will delete those variables from memory!!"
		local errorexistenvar=1
	}
}

if "`t'"=="" {
	local t_present 0
	tempvar t
	qui gen byte `t' = 1
}
else {
	local t_present 1
}

sort `t' `i' `p'

cap levelsof `t', local(year_levels)

quietly levelsof `t', local(Nt)
global Nnt: word count `Nt'


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

foreach y of local year_levels{
		if `t_present' == 1  & $Nnt > 1 { 
			display "`y'", _c
		}
		cap use "`newfile1'", clear

		cap keep if `t'==`y'
		
		
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
		
		if ("`pop'" ~= "" & `rpop' ~= -1) {
			local calculate_rpop 1	
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
		else if `rpop' ~= -1 {
			noi di "Warning: You specified an rpop threshold but did not provide pop variable!!!"
			exit
		}
		else {
			local calculate_rpop 0
		}
		
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
		
		load_export_mata `t' `i' `p' `val' `touse'
		
		if $error_code == 1 exit
		
		if `calculate_rpop' == 0 {
			if `rca' == -1 {
				local rca 1
			}
			complexity_rca
			mata M = (RCA:>`rca')
		}
		
		else if `calculate_rpop' == 1 & `rca' == -1 {
			load_population_mata `i' `pop' `touse'
			complexity_rpop
			mata M = (RPOP:>`rpop')
		}
		
		if $error_code == 1 exit
		
		else if `calculate_rpop' == 1 & `rca' != -1 {
			load_population_mata `i' `pop' `touse'
			complexity_rca
			complexity_rpop
			mata M1 = (RCA:>`rca')
			mata M2 = (RPOP:>`rpop')
			mata M = M1 + M2 
			mata M = (M:>0)
		}
		
		if "`cont'"~="" {
			*noi display "	: Continuous"
			proxcontinous, levels(RCA)
		}	
		else {
			*noi display "	: Discrete"
			proxdiscrete, `asym'
		}
		
		calculate_density, knn(`knn') `cont'  levels(RCA)
		
		
		*============================================================
		
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
		foreach var in M density { 
   			mata tostata = colshape(`var',1)
   			qui mata newvar_row = st_addvar("double", "`var'")
  			qui mata st_store(.,newvar_row,"`touse'",tostata)
		}
		
		 quietly{   		 
		 	// saves the results for the year, opens the file were we store the data 
			save "`newfile3'", replace
			use  "`newfile2'", clear
			append using "`newfile3'"
			save "`newfile2'", replace
		}
}

if `dropped_zero' == 1 append using "`newfile4'"

*=====================================================================================
cap label var year "Year"
cap label var rca "Revealed Comparative Advantage (RCA)"
cap label var rpop "Revealed per capita Advantage (RPOP)"
cap label var density "Product Density "
*=====================================================================================
di " "
* Options for RCA and Rpop
if `calculate_rpop' == 0 {
	display " : Using  RCA with threshold of `rca'"
}
		
else if `calculate_rpop' == 1 & `rca' == -1 {
	display " : Using Rpop with threshold of `rpop'" 	
}		
		
else if `calculate_rpop' == 1 & `rca' != -1 {
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


*=====================================================================================		
display "________________________________________________________________________________________________"
*=====================================================================================
end
