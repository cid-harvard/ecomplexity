*===========================================================================		
// Proximity calculations / using correlations
capture program drop proxcontinous
program proxcontinous
syntax [anything(name=var)], levels(name)
	mata proximity = 0.5:*(1:+ correlation(`levels')) - I(Npx)
	mata country_proximity = 0.5:*(1:+ correlation(`levels'')) - I(Nix)
end
*===========================================================================
