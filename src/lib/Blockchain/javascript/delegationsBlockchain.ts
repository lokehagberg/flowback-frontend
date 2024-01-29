import { ethers } from 'ethers';
import contractABI from './contractDelegationsABI.json';


const getContract = (privateKey:string) => {
	const provider = new ethers.providers.InfuraProvider(import.meta.env.INFURA_API_KEY);

	const wallet = new ethers.Wallet(privateKey, provider);

	//GAS LIMIT ERROR
	// const contractAddress = '0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85';

	const contractAddress = '0x0f021dba3e86994176da8abb497e5a6380439147';

	return new ethers.Contract(contractAddress, contractABI, wallet);
};


export const becomeMemberOfGroup = async (groupId: number, privateKey:string) => {
	const contract = getContract(privateKey);
	
	// Set gasPrice value
	const gasPrice = ethers.utils.parseUnits('20', 'gwei');
	
	// Update transaction options with gasPrice
	const tx = await contract.giveRightToVote(groupId.toLocaleString(), { gasLimit: 500000, gasPrice });
	
	
	// Adjust the timeout based on your requirements
	const txReceipt = await tx.wait({ timeout: 2000 }).catch((error:any) => {
		console.error('Error waiting for transaction:', error);
	});
	
	
	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		console.log(txReceipt);
	} else console.warn('Transaction failed');
};

export const delegate = async (groupId: number, reciever: any, privateKey:string) => {
	const contract = getContract(privateKey);

	console.log(groupId, reciever);
	const tx = await contract.delegate(groupId.toString(), reciever.toString());

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		console.log('Transaction successful');
		console.log(txReceipt.logs);
	}
};
export const becomeDelegate = async (groupId: number, privateKey:string) => {
	const contract = getContract(privateKey);
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
