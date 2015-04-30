*===========================================================================		
// Calculate Pietrenero Complexity Values
capture program drop pietronero
program pietronero
syntax [anything(name=var)], [pietnum(real 50)]

	mata piet_c = J(Nix, 1, 1)
	mata piet_p = J(Npx, 1, 1) 
	
	forvalues iteration=1/`pietnum' {
	
		mata piet_cn = M * piet_p
		mata piet_c = J(Nix, 1, 1) :/ piet_c
		mata piet_pn = M' * piet_c
		mata piet_pn = J(Npx, 1, 1) :/ piet_pn
		
		mata piet_cnmean = mean(piet_cn)
		mata piet_pnmean = mean(piet_pn)
		
		mata piet_c = piet_cn :/ J(Nix, 1, piet_cnmean)
		mata piet_p = piet_pn :/ J(Npx, 1, piet_pnmean)
	}
	
	mata piet_c = piet_c * J(1, Npx, 1)
	mata piet_p = J(Nix, 1, 1) * piet_p'

end
