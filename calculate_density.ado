*------------------------------------------------------------------------------		
* Density calculations
*------------------------------------------------------------------------------
* ::::-> Output: density matrix
*------------------------------------------------------------------------------
capture program drop calculate_density
program calculate_density
syntax [anything(name=var)], [knn(real -1) knnt(real -1) levels(name) proxmatrix(name) cont leaveout asym]
	noi di "PRODUCT Density"
	
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
		mata weight1 = `proxmatrix'':/(J(Npx,Npx,1)* `proxmatrix'')
		mata density = `levels'*weight1
		mata temp_density = density
	}
	
	mata st_global("Np", strofreal(Npx))
	*noi di "leaveout `leaveout' Cont `cont' Knn `knn'"
	else if `knn' ~= -1 & "`leaveout'"=="" {
		mata simi = J(Npx,Npx,0)
		/*
		// OLD> =  Muhammed was sorting columns, should be sorting within each row
		forval i = 1/$Np { 			
			mata temp = sort(`proxmatrix'[.,`i'],-1)
			mata simi[.,`i'] = `proxmatrix'[.,`i'] :* (`proxmatrix'[.,`i'] :>= temp[`knn'])
		}
		*/
		// new, sorting within rows, May 2016
		mata Closest_Proximity = J($Np, 1, 0)
		mata Closest_knn_Proximity = J($Np, 1, 0)
		
		forval i = 1/$Np { 			
			mata temp = sort( `proxmatrix'[`i',.]' , -1)
			mata Closest_Proximity[`i', 1] =  temp[1]
			mata Closest_knn_Proximity[`i', 1] =  temp[`knn']
			mata temp[`knn'] = (temp[`knn'] + `knnt' + abs(temp[`knn'] - `knnt'))/2
			mata simi[`i',.] =  `proxmatrix'[`i',.] :* (`proxmatrix'[`i',.] :>= temp[`knn'])
		}
		mata weight = simi':/(J(Npx,Npx,1)* simi')
		mata weight = editmissing(weight, 0)
		*mata sum_simi = (J(Npx,Npx,1)* simi') + ((J(Npx,Npx,1)* simi' :== 0)
		*mata weight = simi':/(sum_simi)
		mata density = `levels' * weight
		mata weight2 = weight
	}
	
	else if "`leaveout'"~=""{ 
		noi display "	: Excluding countries while calculating Product Density using `levels'"
		mata density = J(Nix, Npx, 0)
		local k_temp = `knn'
		
		if `knn' != -1 {
			mata knn_matrix = J(Npx,Npx,0)
			forval i = 1/$Np { 			
				*mata temp = sort(`proxmatrix'[.,`i'],-1)
				*mata knn_matrix[.,`i'] = (`proxmatrix'[.,`i'] :>= temp[`knn'])
				
				mata temp = sort(`proxmatrix'[`i',.]',-1)
				mata knn_matrix[.,`i'] = (`proxmatrix'[`i',.] :>= temp[`knn'])
			}
		}
		else {
			mata knn_matrix = J(Npx,Npx,1)
		}
		
		forval i = 1/$Ni {
			
			mata temp_v = J(Nix,1,1) // This indicator vector is going to be used to eliminate the ith row of the diagonal matrix
			mata temp_v[`i', 1] = 0 // Change the ith element of the indicator vector to 0					
			
			
			if "`cont'"~="" {
				mata temp_rca = select(`levels',temp_v)
				mata proximity_temp = 0.5:*(1:+ correlation(temp_rca))-I(Npx)
				mata proximity_temp = correlation(temp_rca)-I(Npx)
			}
			else {
				*noi display "	: Discrete"
				mata temp_M = select(`levels',temp_v)
				mata C = temp_M'*temp_M // This gives the size of the overlap between countries that make both products p and p' = C_p,p
				mata S = J(Npx,Nix,1)*temp_M // This gives a matrix whose columns are formed by ubiquity of the products by every row = S_p,p
				mata P1 = C:/S' 	// Now we divide overlap by the ubiquity of the columns and transpose. 
									// Hence this matrix is normalized by the rows = P1_p,p'
				
				if "`asym'"~="" {
					*noi display "	: Asymmetric"
					mata proximity_temp = P1 - I(Npx)
				}	
				
				else {
					*noi display "	: Symmetric"
					mata P2 = C:/S
					mata proximity_temp = (P1+P2 - abs(P1-P2))/2 - I(Npx)
				} 
			}
			mata filtered_proximity = proximity_temp:*(proximity_temp :>= `knnt'):*knn_matrix
			mata weight_temp = (filtered_proximity' :/ (J(Npx,Npx,1)*filtered_proximity'))
			mata weight_temp = editmissing(weight_temp, 0)
			mata density[`i',.] = `levels'[`i',.] * weight_temp
			
			
			*mata S = invsym(variance(temp_rca', 1))
			*mata simi_temp = J(Npx,Npx,0)
			*forval p = 1/$Np {
				*mata mZ = temp_rca :- temp_rca[.,`p']
				*mata simi_p = sqrt(diagonal(mZ'*S*mZ))
				
				*mata temp = sort(proximity_temp[.,`p'],-1)
				*mata simi_temp[.,`p'] = proximity_temp[.,`p'] :* (proximity_temp[.,`p'] :>= temp[`k_temp'])
				*mata simi_p = simi_temp[.,`p']
				*mata simi_p = simi_p:/(J(1,Npx,1)*simi_p)
				
				*mata density[`i',`p']= `levels'[`i',.]*simi_p
			*}
		}
	}
end	
*===========================================================================
