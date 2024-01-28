import { ethers } from 'ethers';

export const newWallet = async () => {
	const provider = new ethers.providers.InfuraProvider(import.meta.env.INFURA_API_KEY);

	const balance = await provider.getBalance("0x73BCEb1Cd57C711fwaC4224D062b0F6#338501e")
	console.log(balance, "BALANCE")

	const userWallet = ethers.Wallet.createRandom();
	let wallet = new ethers.Wallet(userWallet.privateKey);

	let walletWithProvider = new ethers.Wallet(wallet.privateKey, provider);
	return walletWithProvider;
};
