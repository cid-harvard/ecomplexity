*------------------------------------------------------------------------------		
* Density calculations
*------------------------------------------------------------------------------
* ::::-> Output: density matrix
*------------------------------------------------------------------------------
capture program drop calculate_density
program calculate_density
syntax [anything(name=var)], [knn(real -1) levels(name) proxmatrix(name) cont self ]
	*noi di "NEW Density"
	
	if ("`proxmatrix'" == "") {
		local proxmatrix proximity
	}
	if `knn' == -1 {
		if "`cont'"~="" {
			noi display "	: Continuous"
			*noi di "`levels'"
			if("`levels'" == "") {
				mata density = ((RCA*`proxmatrix'):/(J(Nix,Npx,1)*`proxmatrix'))
			}
			else {
				mata density = ((`levels'*`proxmatrix'):/(J(Nix,Npx,1)*`proxmatrix'))
			}
		}	
		else {
			noi display "	: Discrete"
			mata density = ((M*`proxmatrix'):/(J(Nix,Npx,1)*`proxmatrix'))
		}
	}
	else {
		mata simi = J(Npx,Npx,0)
		forval i = 1/$Np { 			
			mata temp = sort(`proxmatrix'[.,`i'],-1)
			mata simi[.,`i'] = `proxmatrix'[.,`i'] :* (`proxmatrix'[.,`i'] :>= temp[`knn'])
		}
		mata weight = simi:/(J(Npx,Npx,1)* simi)
		
		if "`cont'"~="" & "`self'"=="" {
			noi display "	: Continuous and using knn = `knn'"
			noi di "`levels'"
			if("`levels'" == "") {
				mata density = RCA * weight
			}
			else {				
				mata density = `levels' * weight 
			}
		}	
		*else {
		*	noi display "	: Discrete and using knn = `knn'"
		*	mata density = M * weight
		*}
		//--------------------------------------------------------------------------------
		
		*noi di "`self'"
		if "`self'"~="" & `knn'>0 { 
		// &  "`cont'"~="" { 
				noi display "	: Excluding countries and continuous"
				mata density = J(Nix, Npx, 0)
				local k_temp = `knn'
				if `knn' == -1 {
					local k_temp = $Npx
				}
				
				forval i = 1/$Ni {
					mata temp_v = J(Nix,1,1) // This indicator vector is going to be used to eliminate the ith row of the diagonal matrix
					mata temp_v[`i', 1] = 0 // Change the ith element of the indicator vactor to 0					
					// mata temp_rca = select(RCA,temp_v)
					mata temp_rca = select(`levels',temp_v)					
					mata `proxmatrix'_temp = 0.5:*(1:+ correlation(temp_rca))-I(Npx)
					mata simi_temp = J(Npx,Npx,0)					
						forval p = 1/$Np {		
							mata temp = sort(`proxmatrix'_temp[.,`p'],-1)
							mata simi_temp[.,`p'] = `proxmatrix'_temp[.,`p'] :* (`proxmatrix'_temp[.,`p'] :>= temp[`k_temp'])
							mata simi_p = simi_temp[.,`p']
							mata simi_p = simi_p:/(J(1,Npx,1)*simi_p)
							// mata density[`i',`p']= RCA[`i',.]*simi_p
							mata density[`i',`p']= `levels'[`i',.]*simi_p
						}
				}
		}
		*--------------------------------------------------------------------------------
		// else {
		//	noi display ":: nothing"
		// }		
		*--------------------------------------------------------------------------------

	}
end	
*===========================================================================
