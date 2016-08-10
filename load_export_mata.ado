capture program drop load_export_mata
program load_export_mata
syntax varlist
	
	tokenize "`varlist'"
	local t = "`1'"
	local i = "`2'"
	local p = "`3'"
	local val = "`4'"
	local touse = "`5'"
	
	cap fillin  `i' `p' `t'
	cap replace `val'= 0 if _fillin==1
	cap drop _fillin

	foreach j in i p {
		egen id_`j' = group(``j'')
		qui sum id_`j'
		global N`j' = r(max)
		mata N`j'x=strtoreal(st_global("N`j'"))
	}
	
	qui replace `touse' = 1
	qui count if `touse'
	
	if r(N)~=$Ni*$Np {
		noi di in re "Not rectangular, might need to specify the time (t) dimension!"
		global error_code = 1
		exit
	}
	sort `t' `i' `p' 
	/// matrix calculations 		
	mata temp_long=st_data(.,"`val'", "`touse'") // loads values of export/production into the matrix in long format
	mata exp_cp = rowshape(temp_long,Nix)  // reshape the data into a square matrix
	
end
