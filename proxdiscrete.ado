*===========================================================================		
// Proximity calculations / using co-ocurrence
capture program drop proxdiscrete
program proxdiscrete
syntax [anything(name=var)], [asym]
	
	mata C = M'*M
	mata S = J(Npx,Nix,1)*M
	mata P1 = C:/S
	
	mata C_c = M*M'
	mata S_c = M*J(Npx,Nix,1)
	mata P1_c = C_c:/S_c
	
	if "`asym'"~="" {
		*noi display "	: Asymmetric"
		mata proximity = P1 - I(Npx)
		mata country_proximity = P1_c - I(Nix)
	}	
	
	else {
		*noi display "	: Symmetric"
		mata P2 = C:/S'
		mata proximity = (P1+P2 - abs(P1-P2))/2 - I(Npx)
		
		mata P2_c = C_c:/S_c'
		mata country_proximity = (P1_c+P2_c - abs(P1_c-P2_c))/2 - I(Nix)
	}
end	
*===========================================================================

