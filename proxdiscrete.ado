*===========================================================================		
// Proximity calculations / using co-ocurrence
capture program drop proxdiscrete
program proxdiscrete
syntax [anything(name=var)], [asym]
	
	mata C = M'*M // This gives the size of the overlap between countries that make both products p and p' = C_p,p
	mata S = J(Npx,Nix,1)*M // This gives a matrix whose columns are formed by ubiquity of the products by every row = S_p,p
	mata P1 = C:/S' 	// Now we divide overlap by the ubiquity of the columns and transpose. 
						// Hence this matrix is normalized by the rows = P1_p,p'
	
	mata C_c = M*M' // Overlap between the products made by countries c and c' = C_c,c'
	mata S_c = M*J(Npx,Nix,1) // This gives a matrix whose rows are diversity of the country c = S_c,c
	mata P1_c = C_c:/S_c 	// Now we divide overlap by the diversity of the rows. 
							// Hence this matrix is normalized by the rows = (P1_c)_c,c'
	
	if "`asym'"~="" {
		*noi display "	: Asymmetric"
		mata proximity = P1 - I(Npx)
		mata country_proximity = P1_c - I(Nix)
	}	
	
	else {
		*noi display "	: Symmetric"
		mata P2 = C:/S
		mata proximity = (P1+P2 - abs(P1-P2))/2 - I(Npx)
		
		mata P2_c = C_c:/S_c'
		mata country_proximity = (P1_c+P2_c - abs(P1_c-P2_c))/2 - I(Nix)
	}
end	
*===========================================================================

