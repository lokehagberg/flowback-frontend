import { ethers } from 'ethers';
import contractABI from './contractDelegationsABI.json';


const getContract = (privateKey:string) => {
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.INFURA_API_KEY);

	const wallet = new ethers.Wallet(privateKey, provider);


	const contractAddress = '0x616F8F6C731f805C4Ae7D0D315cD97877F99745a';

	return new ethers.Contract(contractAddress, contractABI, wallet);
};


export const becomeMemberOfGroup = async (groupId: number, privateKey:string) => {
	const contract = getContract(privateKey);
	
	// Set gasPrice value
	const gasPrice = ethers.utils.parseUnits('0.000000001', 'gwei');
	
	// Update transaction options with gasPrice
	const tx = await contract.giveRightToVote(groupId, { gasLimit: 21204, gasPrice });
	
	
	// Timeout for when the transactions takes too long
	const txReceipt = await tx.wait({ timeout: 20000 }).catch((error:any) => {
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
