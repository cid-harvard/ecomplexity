*===========================================================================		
// Calculate ECI and PCI
capture program drop coicog
program coicog

// Complexity Outlook Index / Opportunity Value
    mata coi = ((density:*(1 :- M)):*kp)*J(Npx,Npx,1)
    
// Complexity Outlook Gain
    *mata cog = (J(Nix,Npx,1) - M):*((J(Nix,Npx,1) - M) * ///
               *(proximity :* ((kp1d:/(proximity*J(Npx,1,1)))*J(1,Npx,1))) - (density:*(J(Nix,Npx,1) - M)):*kp)
    
    mata cog = (1 :- M):*((1 :- M) * (proximity :* ((kp1d:/(proximity*J(Npx,1,1)))*J(1,Npx,1))))

end
