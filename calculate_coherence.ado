*===========================================================================		
* File has two posible measures of coherence
*===========================================================================		
/*
// Coherence Calculations  // Sebastian's Measure
capture program drop calculate_coherence
program calculate_coherence

	mata coh_c = J(Nix, 1, 1)
	mata coh_p = J(Npx, 1, 1) 
	
	forvalues c=1/$Ni {
		loc	c = 1
		mata tempc = M[`c',.] :*  proximity
		mata tempc[1,.]
		mata tempc[2,.]
		
		mata coh_c[`c'] = sum(tempc[1,.])/sum(M[`c',.])
		mata coh_c
	}
	
	
	mata tempc = M  :*  proximity
	mata mata des tempc
	mata tempc[1,]
	
	forvalues p=1/$Np {
		mata tempp = M[.,`p'] :*  country_proximity
		mata coh_p[`c'] = sum(tempp[1,.])/sum(M[.,`p'])
		
	}
	
	*mata coh_c = coh_c * J(1, Npx, 1)
	*mata coh_p = J(Nix, 1, 1) * coh_p'
end	
*/
*===========================================================================


*===========================================================================		
// Coherence Calculations  // Muhammed's Measure
capture program drop calculate_coherence
program calculate_coherence

	mata coh_c = J(Nix, 1, 1)
	mata coh_p = J(Npx, 1, 1) 
	
	forvalues c=1/$Ni {
		mata M_c = M[`c',.]
		mata M_pp = M_c * M_c'
		mata coh_c[`c'] = sum(M_pp :* proximity)
		
	}
	
	forvalues p=1/$Np {
	
		mata M_p = M[.,`p']
		mata M_cc = M_p * M_p'
		mata coh_p[`p'] = sum(M_cc :* country_proximity)
		
	}
	
	mata coh_c = coh_c * J(1, Npx, 1)
	mata coh_p = J(Nix, 1, 1) * coh_p'
end	
*===========================================================================
