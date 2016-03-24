capture program drop load_population_mata
program load_population_mata
syntax varlist

	tokenize "`varlist'"
	local i = "`1'"
	local pop = "`2'"
	local touse = "`3'"
	
	quietly{
		tempvar temppop
		egen `temppop' = mean(`pop'), by(`i')
		replace `pop' = `temppop'
		drop `temppop'
	}
	
	mata temp_long=st_data(.,"`pop'", "`touse'") // loads values into the matrix in long format 
	mata pop_cp = rowshape(temp_long,Nix)  // reshape the data into a square matrix
end
