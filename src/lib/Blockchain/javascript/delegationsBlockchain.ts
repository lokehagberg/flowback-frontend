import { ethers } from 'ethers';
import contractABI from './contractDelegationsABI.json'

const getContract = () => {
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.INFURA_API_KEY);

	console.log("0x160ed76d55ea463f901cd3734357d2698a6a165782a4b2af9b51668fe1ab8310");

	const wallet = new ethers.Wallet("0x160ed76d55ea463f901cd3734357d2698a6a165782a4b2af9b51668fe1ab8310", provider);

	const contractAddress = '0x0f021dba3e86994176da8abb497e5a6380439147';

	return new ethers.Contract(contractAddress, contractABI, wallet);
};

export const delegate = async (groupId: number, reciever: any) => {
	const contract = getContract();

	const tx = await contract.delegate(groupId, reciever);

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		// console.log('Transaction successful');
		// console.log (txReceipt.logs);
	}
};

export const becomeMemberOfGroup = async (groupId: number) => {
	const contract = getContract();

	const tx = await contract.giveRightToVote(groupId);

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		console.log(txReceipt);
	}
};

export const becomeDelegate = async (groupId: number) => {
	const contract = getContract();
	console.log('HERE');
	const tx = await contract.becomeDelegate(groupId);

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		const logs = txReceipt.logs;
		console.log(logs);

		const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
		console.log(parsedLogs);
	}
};

//becomeMemberOfGroup(1)
//becomeDelegate(1);

//delegate(1,"adress");
