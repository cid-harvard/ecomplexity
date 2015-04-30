*------------------------------------------------------------------------------		
* Density calculations
*------------------------------------------------------------------------------
* ::::-> Output: Country Space based density matrix
*------------------------------------------------------------------------------
capture program drop calculate_country_density
program calculate_country_density
syntax [anything(name=var)], [knn(real -1) levels(name) proxmatrix(name) cont self ]
	*noi di "NEW Density"
	
	if ("`proxmatrix'" == "") {
		local proxmatrix country_proximity
	}
	if("`levels'" == "") {
		local levels RCA
	}
	if `knn' == -1 {
		if "`cont'"~="" {
			noi display "	: Continuous"
			*noi di "`levels'"
			mata country_density = ((`levels''*`proxmatrix'):/(J(Npx,Nix,1)*`proxmatrix'))
		}	
		else {
			noi display "	: Discrete"
			mata country_density = ((M'*`proxmatrix'):/(J(Npx,Nix,1)*`proxmatrix'))
		}
	}
	else {
		mata simi = J(Nix,Nix,0)
		forval i = 1/$Ni { 			
			mata temp = sort(`proxmatrix'[.,`i'],-1)
			mata simi[.,`i'] = `proxmatrix'[.,`i'] :* (`proxmatrix'[.,`i'] :>= temp[`knn'])
		}
		mata weight = simi:/(J(Nix,Nix,1)* simi)
		
		if "`cont'"~="" & "`self'"=="" {
			noi display "	: Continuous and using knn = `knn'"
			noi di "`levels'"				
			mata country_density = `levels'' * weight 
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
				mata country_density = J(Npx, Nix, 0)
				local k_temp = `knn'
				if `knn' == -1 {
					local k_temp = $Nix
				}
				
				forval i = 1/$Np {
					mata temp_v = J(Npx,1,1) // This indicator vector is going to be used to eliminate the ith row of the diagonal matrix
					mata temp_v[`i', 1] = 0 // Change the ith element of the indicator vactor to 0					
					// mata temp_rca = select(RCA,temp_v)
					mata temp_rca = select(`levels'',temp_v)
					mata temp_count = (`levels'[.,`i'])'
					mata `proxmatrix'_temp = 0.5:*(1:+ correlation(temp_rca))-I(Nix)
					mata simi_temp = J(Nix,Nix,0)					
						forval p = 1/$Ni {		
							mata temp = sort(`proxmatrix'_temp[.,`p'],-1)
							mata simi_temp[.,`p'] = `proxmatrix'_temp[.,`p'] :* (`proxmatrix'_temp[.,`p'] :>= temp[`k_temp'])
							mata simi_p = simi_temp[.,`p']
							mata simi_p = simi_p:/(J(1,Nix,1)*simi_p)
							mata country_density[`i',`p']= `levels'[`i',.]*simi_p
						}
				}
		}
		*--------------------------------------------------------------------------------
		// else {
		//	noi display ":: nothing"
		// }		
		*--------------------------------------------------------------------------------
	
	}
	mata country_density = country_density'
end	
*===========================================================================
