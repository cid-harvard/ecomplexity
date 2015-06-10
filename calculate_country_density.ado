*------------------------------------------------------------------------------		
* Density calculations
*------------------------------------------------------------------------------
* ::::-> Output: Country Space based density matrix
*------------------------------------------------------------------------------
capture program drop calculate_country_density
program calculate_country_density
syntax [anything(name=var)], [knn(real -1) levels(name) proxmatrix(name) cont leaveout ]
	*noi di "COUNTRY Density"
	*noi di "Country `leaveout'"
	
	if ("`proxmatrix'" == "") {
		local proxmatrix country_proximity
	}
	if ("`levels'" == "" & "`cont'"~="") {
		local levels RCA
		*noi di "Set Continous Country density variable to RCA"
	}
	if ("`levels'" == "" & "`cont'"=="") {
		local levels M
		*noi di "Set Discrete Country density variable to M"
	}
	
	if `knn' == -1 & "`leaveout'"==""{
		mata country_density = ((`levels''*`proxmatrix'):/(J(Npx,Nix,1)*`proxmatrix'))
	}

	else if `knn' ~= -1 & "`leaveout'"=="" {
		mata simi = J(Nix,Nix,0)
		forval i = 1/$Ni { 			
			mata temp = sort(`proxmatrix'[.,`i'],-1)
			mata simi[.,`i'] = `proxmatrix'[.,`i'] :* (`proxmatrix'[.,`i'] :>= temp[`knn'])
		}
		mata weight = simi:/(J(Nix,Nix,1)* simi)
		mata country_density = `levels'' * weight 	
		*noi di "Here 2"
	}
	
	else if "`leaveout'"~=""{ 
		*noi display "	: Excluding products while calculating Country Density"
		*noi di "Here 3"
		mata country_density = J(Npx, Nix, 0)
		local k_temp = `knn'
		if `knn' == -1 {
			local k_temp = $Ni
			*noi di "ktemp is `k_temp' and Number of countries $Ni"
		}
		forval i = 1/$Np {
			mata temp_v = J(Npx,1,1) // This indicator vector is going to be used to eliminate the ith row of the diagonal matrix		
			mata temp_v[`i', 1] = 0 // Change the ith element of the indicator vactor to 0					
			mata temp_rca = select(`levels'',temp_v)
			mata temp_count = (`levels'[.,`i'])'
			mata `proxmatrix'_temp = 0.5:*(1:+ correlation(temp_rca))-I(Nix)
			mata simi_temp = J(Nix,Nix,0)					
		
			forval p = 1/$Ni {
				mata temp = sort(`proxmatrix'_temp[.,`p'],-1)
				mata simi_temp[.,`p'] = `proxmatrix'_temp[.,`p'] :* (`proxmatrix'_temp[.,`p'] :>= temp[`k_temp'])
				mata simi_p = simi_temp[.,`p']
				mata simi_p = simi_p:/(J(1,Nix,1)*simi_p)
				mata country_density[`i',`p']= temp_count*simi_p
			}
		}
	}
	
	mata country_density = country_density'
end	
*===========================================================================
