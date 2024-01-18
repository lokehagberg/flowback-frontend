import { ethers } from 'ethers';
import contractABI from './contractDelegationsABI.json'

const getContract = () => {
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.VITE_INFURA_API_KEY);

	const wallet = new ethers.Wallet(import.meta.env.VITE_SIGNER_PRIVATE_KEY, provider);

	//GAS LIMIT
	// const contractAddress = '0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85';
	
	//REPLACEMENT FEE
	const contractAddress = '0x0f021dba3e86994176da8abb497e5a6380439147';

	return new ethers.Contract(contractAddress, contractABI, wallet);
};

export const delegate = async (groupId: number, reciever: any) => {
	const contract = getContract();

	console.log(groupId, reciever)
	const tx = await contract.delegate(groupId.toString(), reciever.toString());

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		console.log (txReceipt.logs);
	}
};

export const becomeMemberOfGroup = async (groupId: number) => {
	const contract = getContract();
	console.log(contract.estimateGas, 'GAAAAS');
	const tx = await contract.giveRightToVote(groupId.toLocaleString(), {gasLimit:500000, gasPrice: ethers.utils.parseUnits('20', 'gwei')});
	console.log("here")
	const txReceipt = await tx.wait(2000);
	console.log("here")

	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		console.log(txReceipt);
	}
	else console.warn("Transaction failed")
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
