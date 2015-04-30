capture program drop complexity_rpop
program complexity_rpop
	mata exp_p= J(Nix,Nix,1) * exp_cp
	mata pop_tot = sum(pop_cp)/Npx
	mata RPOP = (exp_cp:/exp_p):/(pop_cp:/pop_tot)
end
