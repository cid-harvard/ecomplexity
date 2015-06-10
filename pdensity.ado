*----------------------------------------------------------------------------------------
cap program drop pdensity
program define pdensity
*----------------------------------------------------------------------------------------

syntax varlist [if/], i(varlist) p(varlist) [t(varlist) pop(varlist) rca(real 1) rpop(real -1) knn(real -1) contp contd leaveout im(varlist) asym]
marksample touse
*----------------------------------------------------------------------
*----------------------------------------------------------------------
tokenize "`varlist'"
local val = "`1'"
global error_code = 0
local dropped_zero = 0


*----------------------------------------------------------------------
// Drop Variables that can confuse the output
*----------------------------------------------------------------------
local errorexistenvar=0
local create_variables M RCA RPOP rca rpop mcp density eci pci coi cog kc0 kp0 diversity ubiquity _merge _fillin id_i id_p
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
*----------------------------------------------------------------------
* Sort variables and prepare datasets 
*----------------------------------------------------------------------
sort `t' `i' `p'
cap levelsof `t', local(year_levels)
quietly levelsof `t', local(Nt)
global Nnt: word count `Nt'
display " "
display "Calculates density"
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
*----------------------------------------------------------------------

//============================================================================================================
foreach y of local year_levels{ // starting main loop
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
		
		*------------------------------------------------
		* Checks data for the running year
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
		
		*------------------------------------------------
		* Loads data into Mata matrices 
		*------------------------------------------------
		load_export_mata `t' `i' `p' `val' `touse' // outpu: exp_cp
		if $error_code == 1 exit // error checking
		*------------------------------------------------
		
		complexity_rca
		mata M = (RCA:>`rca')
		noi di "RCA threshold is `rca'"
		if "`contp'"~=""{
			proxcontinous, levels(RCA)
		}
		else{
			proxdiscrete
		}

		if "`contd'"~=""{
			calculate_density, knn(`knn') cont `leaveout'
			calculate_country_density, knn(`knn') cont `leaveout'
		}
		else {
			calculate_density, knn(`knn') `leaveout'
			calculate_country_density, knn(`knn') `leaveout'
		}
		
		*------------------------------------------------------------------------------
		* Turns matrices into stata dataset shape
		*------------------------------------------------------------------------------
		foreach var in density country_density{ 
   			mata tostata = colshape(`var',1)
   			qui mata newvar_row = st_addvar("double", "`var'")
  			qui mata st_store(.,newvar_row,"`touse'",tostata)
		}
		
		*------------------------------------------------------------------------------
		// saves the results for the year, opens the file were we store the data 
		*------------------------------------------------------------------------------
		drop id_i
		drop id_p
		quietly {
			save "`newfile3'", replace
			use  "`newfile2'", clear
			append using "`newfile3'"
			save "`newfile2'", replace
		}
		
} // closing main loop
//============================================================================================================		
if `dropped_zero' == 1 append using "`newfile4'"




*=====================================================================================		
display "________________________________________________________________________________________________"
*=====================================================================================
end
