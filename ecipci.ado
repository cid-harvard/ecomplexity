*===========================================================================		
// Calculate ECI and PCI
capture program drop ecipci
program ecipci

	mata kc0 = M*J(Npx,Npx,1) 
	mata kp0 = J(Nix,Nix,1)* M
	mata kc0_all = M*J(Npx,Npx,1)

	mata Mptilde=((M:/kp0):/kc0)'*M
	mata eigensystem(Mptilde,Vp=.,lp=.)		
	mata kp=Re(Vp[.,2]) 			// complexity: second eigenvector
	mata kc = (M:/kc0_all) * kp				// complexity: second eigenvector

	mata kc01d = M*J(Npx,1,1)
	mata eigensign = 2*(correlation((kc01d, kc))[1,2] > 0) - 1
	mata kp = eigensign :* kp
	mata kc = eigensign :* kc

	mata kc = kc*J(1,Npx,1)
	mata kp1d = kp
	mata kp = J(Nix,1,1)*kp'

end
