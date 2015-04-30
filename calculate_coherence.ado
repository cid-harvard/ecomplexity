*===========================================================================		
// Coherence Calculations
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
