*===========================================================================		
// Proximity calculations / using correlations
capture program drop proxcontbootstrap
program proxcontbootstrap
syntax [varlist], maxiter(real 10)

	mata proximity = J(Npx, Npx, 0)
	forvalues iter = 1/`maxiter' {
		mata temp_levels = `levels'[ceil(Npx * uniform(Npx, 1))]
		mata temp_proximity = 0.5:*(1:+ correlation(temp_levels)) - I(Npx)
		mata proximity = proximity + temp_proximity
	}	
	mata proximity = proximity:/`maxiter'

end
