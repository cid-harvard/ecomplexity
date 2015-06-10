*------------------------------------------------------------------------------		
* Density calculations
*------------------------------------------------------------------------------
* ::::-> Output: density matrix
*------------------------------------------------------------------------------
capture program drop calculate_density
program calculate_density
syntax [anything(name=var)], [knn(real -1) levels(name) proxmatrix(name) cont leaveout ]
	*noi di "PRODUCT Density"
	
	if ("`proxmatrix'" == "") {
		local proxmatrix proximity
	}
	if ("`levels'" == "" & "`cont'"~="") {
		local levels RCA
		*noi di "Set Product density variable to RCA"
	}
	if ("`levels'" == "" & "`cont'"=="") {
		local levels M
		*noi di "Set Product density variable to M"
	}
	
	if `knn' == -1 & "`leaveout'"==""{
		mata weight1 = `proxmatrix':/(J(Npx,Npx,1)* `proxmatrix')
		mata density = ((`levels'*`proxmatrix'):/(J(Nix,Npx,1)*`proxmatrix'))
		*noi di "Here 1"
	}
	
	*noi di "leaveout `leaveout' Cont `cont' Knn `knn'"
	else if `knn' ~= -1 & "`leaveout'"=="" {
		mata simi = J(Npx,Npx,0)
		forval i = 1/$Np { 			
			mata temp = sort(`proxmatrix'[.,`i'],-1)
			mata simi[.,`i'] = `proxmatrix'[.,`i'] :* (`proxmatrix'[.,`i'] :>= temp[`knn'])
		}
		mata weight = simi:/(J(Npx,Npx,1)* simi)
		mata density = `levels' * weight
		mata weight2 = weight
		*noi di "Here 2"
	}
		
	
	else if "`leaveout'"~=""{ 
		*noi display "	: Excluding countries while calculating Product Density"
		mata density = J(Nix, Npx, 0)
		local k_temp = `knn'
		
		if `knn' == -1 {
			local k_temp = $Np
		}
		forval i = 1/$Ni {
			
			mata temp_v = J(Nix,1,1) // This indicator vector is going to be used to eliminate the ith row of the diagonal matrix
			mata temp_v[`i', 1] = 0 // Change the ith element of the indicator vactor to 0					
			mata temp_rca = select(`levels',temp_v)					
			mata `proxmatrix'_temp = 0.5:*(1:+ correlation(temp_rca))-I(Npx)
			mata simi_temp = J(Npx,Npx,0)
			
			forval p = 1/$Np {		
				mata temp = sort(`proxmatrix'_temp[.,`p'],-1)
				mata simi_temp[.,`p'] = `proxmatrix'_temp[.,`p'] :* (`proxmatrix'_temp[.,`p'] :>= temp[`k_temp'])
				mata simi_p = simi_temp[.,`p']
				mata simi_p = simi_p:/(J(1,Npx,1)*simi_p)
				mata density[`i',`p']= `levels'[`i',.]*simi_p
			}
		}
	}
end	
*===========================================================================
