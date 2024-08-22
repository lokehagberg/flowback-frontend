import { ethers } from 'ethers';
import contractABI from './contractABI.json';
import {env} from "$env/dynamic/public";


// const getContract = (privateKey:string) => {
	
// 	const provider = new ethers.providers.InfuraProvider('sepolia', '1d9699a2ff8348839cc8bb35d8cff530');

// 	const wallet = new ethers.Wallet(privateKey, provider);


// 	const contractAddress = '0xf43205cD2E7Ab7416D73cCcFC30cD5d980c9A31a';

// 	return new ethers.Contract(contractAddress, contractABI, wallet);
// };
interface Window {
	ethereum?: import('ethers').providers.ExternalProvider;
  }
  
	async function getUser() {
	  if (window.ethereum) {
		await window.ethereum.request({ method: 'eth_requestAccounts' });
		const provider = new ethers.providers.Web3Provider(window.ethereum);
		const signer = provider.getSigner();
		return signer;
	  } else {
		console.log('MetaMask is not available');
		throw new Error('MetaMask is not available');
	  }
	}
	
	const getContract = async () => {
	  const signer = await getUser();
	  const contractAddress = env.PUBLIC_SIGNER_ADDRESS; //use this address
	  return new ethers.Contract(contractAddress, contractABI, signer);
	};


export const becomeMemberOfGroup = async (_groupId: number) => {
	
	const contract = await getContract();
	const { provider } = await getContract();
	
	const feeData = await provider.getFeeData();
	const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;

	const estimatedGasLimit = await contract.estimateGas.becomeMemberOfGroup(2);
	const tx = await contract.becomeMemberOfGroup(_groupId, { //group id

    gasLimit: estimatedGasLimit, 
    maxPriorityFeePerGas: maxPriorityFeePerGas,
    });

	
	try {
		const txReceipt = await tx.wait({ timeout: 40000 });
		if (txReceipt && txReceipt.status===1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const GroupMembershipChangedEvent = parsedLogs.find((log:any) => log.name === 'GroupMembershipChanged');
            if (GroupMembershipChangedEvent) {
				// indexed user, uint indexed group, bool isMember
                const user = GroupMembershipChangedEvent.args.user;
                const group= GroupMembershipChangedEvent.args.group;
                const isMember = GroupMembershipChangedEvent.args.isMember;
                console.log(`User "${user}" is now member of group ${group}, isMember = "${isMember}"`);
            }
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error waiting for transaction:', error);
	}
	
};

export const removeGroupMembership = async (groupId:number) => {
	
	const contract = await getContract();
	const { provider } = await getContract();
	
	const feeData = await provider.getFeeData();
	const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
	

	const estimatedGasLimit = await contract.estimateGas.removeGroupMembership(groupId);
	const tx = await contract.removeGroupMembership(groupId, { //group id
    gasLimit: estimatedGasLimit, 
    maxPriorityFeePerGas: maxPriorityFeePerGas,
    });

	
	try {
		const txReceipt = await tx.wait({ timeout: 40000 });
		if (txReceipt && txReceipt.status===1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));

			const GroupMembershipChangedEvent = parsedLogs.find((log:any) => log.name === 'GroupMembershipChanged');
            if (GroupMembershipChangedEvent) {
				// indexed user, uint indexed group, bool isMember
                const user = GroupMembershipChangedEvent.args.user;
                const group= GroupMembershipChangedEvent.args.group;
                const isMember = GroupMembershipChangedEvent.args.isMember;
                console.log(`User "${user}" is no longer a member of group ${group}, isMember = "${isMember}"`);
            }
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error waiting for transaction:', error);
	}
	
};
export const isUserMemberInGroup = async () => {
	const contract = await getContract();
	const tx = await contract.isUserMemberOfGroup(1);  //group id
	console.log(tx);
};

export const getGroupsUserIsMemberIn = async () => {
    const contract = await getContract();
	const tx = await contract.getGroupsUserIsMemberIn(); 
	if (tx.length==0) {
		console.log("No groups");
	}else{
		tx.map((groups:any) => console.log(parseInt(groups)))
	}
};