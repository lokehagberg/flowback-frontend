import { ethers } from 'ethers';

export const newWallet = async () => {
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.INFURA_API_KEY);

	// console.log(ethers.utils.formatEther(balance), "BALANCE")

	const userWallet = ethers.Wallet.createRandom();
	let wallet = new ethers.Wallet(userWallet.privateKey);

	let walletWithProvider = new ethers.Wallet(wallet.privateKey, provider);
	return walletWithProvider;
};
