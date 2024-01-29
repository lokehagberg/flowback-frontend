import { ethers } from 'ethers';

export const newWallet = async () => {
	const provider = new ethers.providers.InfuraProvider(import.meta.env.INFURA_API_KEY);

	// const balance = await provider.getBalance("0x857bA91346bB5425A093278b2ccfFce74180d82B")
	// console.log(ethers.utils.formatEther(balance), "BALANCE")

	const userWallet = ethers.Wallet.createRandom();
	let wallet = new ethers.Wallet(userWallet.privateKey);

	let walletWithProvider = new ethers.Wallet(wallet.privateKey, provider);
	return walletWithProvider;
};
