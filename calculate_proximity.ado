cap program drop calculate_proximity
program define calculate_proximity
 
version 10

syntax [varlist  ]  [, i(varlist) p(varlist)]
tokenize "`varlist'"
local val = "`1'"

/// Droping variables that would be output-variables. 
cap drop proximity   
cap drop a_proximity  
cap drop ubiquity_1
cap drop ubiquity_2    
cap drop overlap 
cap drop _fillin
cap drop _merge

sort `i' `p'

quietly levelsof `p', local(Np)

tempvar  touse

// Start the loop tha would calculate variables year by year. 
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

mata M_long = st_data(.,"`val'", "`touse'") // loads values of export/production into the matrix in long format 
mata M = rowshape(M_long,Ncx)  // reshape the data into a square matrix

mata eliminator = I(Ncx)
mata zero_elements = M * J(Npx,1,1)		
mata eliminator = select(eliminator, zero_elements)
mata M = eliminator*M
mata Ncx = rows(M)

mata eliminatory = I(Npx)
mata zero_elements = (J(1,Ncx,1)*M)'		
mata eliminatory = select(eliminatory, zero_elements)
mata M = M*eliminatory'
mata Npx = rows(M')

mata kc0= M*J(Npx,Npx,1) 

// Proximity calculations
mata C = M'*M
mata S = J(Npx,Ncx,1)*M
mata P1 = C:/S
mata P2 = C:/S'    
mata proximity = (P1+P2 - abs(P1-P2))/2 - I(Npx)

// Assymetric Proximity
mata a_proximity = P1 - I(Npx)

drop *
set obs ${Np}
quietly{
	// Generate the variables the will store the output of the matrix calculations
	gen product_1=.
	gen product_2=.
	gen proximity = .
	gen a_proximity = .
	gen ubiquity_1 = .
	gen ubiquity_2 = .
	gen overlap = .
}

forvalues t=1/$Np {
	local e: word `t' of `PRODUCT' 
	quietly replace product_1 =`e' if _n==`t' 
	quietly replace product_2 =`e' if _n==`t' 
}
fillin product_1 product_2
drop _fillin

mata proximity = eliminatory* proximity * eliminatory'
mata temp_long=vec(proximity)
mata st_store(.,"proximity", temp_long)

mata a_proximity = eliminatory* a_proximity * eliminatory'
mata temp_long=vec(a_proximity)
mata st_store(.,"a_proximity", temp_long)

mata S = eliminatory* S * eliminatory'
mata temp_long=vec(S)
mata st_store(.,"ubiquity_1", temp_long)

mata temp_long=vec(S')
mata st_store(.,"ubiquity_2", temp_long)

mata C = eliminatory* C * eliminatory'
mata temp_long=vec(C)
mata st_store(.,"overlap", temp_long)

drop if product_1 == product_2
end 
