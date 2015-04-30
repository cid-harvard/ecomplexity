capture program drop complexity_rca
program complexity_rca
	mata exp_tot = sum(exp_cp)		
	mata exp_p = J(Nix,Nix,1) * exp_cp 	
	mata exp_c = exp_cp * J(Npx,Npx,1)		 						
	mata RCA = (exp_cp:/exp_c):/(exp_p:/exp_tot)
end
