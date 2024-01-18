import { ethers } from 'ethers';

export const newWallet = () => {
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.VITE_INFURA_API_KEY);
	console.log(import.meta.env.VITE_INFURA_API_KEY)

	const userWallet = ethers.Wallet.createRandom();
	let wallet = new ethers.Wallet(userWallet.privateKey);

	let walletWithProvider = new ethers.Wallet(wallet.privateKey, provider);
	return walletWithProvider;
};
