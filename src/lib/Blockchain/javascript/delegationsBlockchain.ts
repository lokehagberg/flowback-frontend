import { ethers } from 'ethers';
import contractABI from './contractABI.json';

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
	  const contractAddress = '0x0fDD2AD1aEE84C91DEb80c25993c0bEde05987A3'; //use this address
	  return new ethers.Contract(contractAddress, contractABI, signer);
	};

export const becomeDelegate = async () => {
	try {
		const contract = await getContract();
		const feeData = await contract.provider.getFeeData();
		const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
		const estimatedGasLimit = await contract.estimateGas.becomeDelegate(2);
		const tx = await contract.becomeDelegate(2, {
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas,
		});

		const txReceipt = await tx.wait({ timeout: 4000 });
		if (txReceipt && txReceipt.status === 1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const NewDelegateEvent = parsedLogs.find(log => log.name === 'NewDelegate');
			if (NewDelegateEvent) {
				const delegate = NewDelegateEvent.args.delegate;
				const groupId = NewDelegateEvent.args.groupId;
				console.log(`New delegate "${delegate}" added to group ${groupId}`);
			} else {
				console.warn('NewDelegate event not found in transaction logs');
			}
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error becoming delegate', error);
	}
}