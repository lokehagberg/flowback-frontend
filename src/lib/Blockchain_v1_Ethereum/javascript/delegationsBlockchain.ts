import { ethers } from 'ethers';
import contractABI from './contractABI.json';
import {env} from "$env/dynamic/public";

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

export const becomeDelegate = async (groupId: number | string) => {
	groupId = Number(groupId);

	try {
		const contract = await getContract();
		const feeData = await contract.provider.getFeeData();
		const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
		const estimatedGasLimit = await contract.estimateGas.becomeDelegate(groupId);
		const tx = await contract.becomeDelegate(groupId, {
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas
		});

		const txReceipt = await tx.wait({ timeout: 4000 });
		if (txReceipt && txReceipt.status === 1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const NewDelegateEvent = parsedLogs.find((log: any) => log.name === 'NewDelegate');
			if (NewDelegateEvent) {
				const delegate = NewDelegateEvent.args.delegate;
				const groupId = NewDelegateEvent.args.groupId;
				console.log(`New delegate "${delegate}" added to group ${groupId}`);
				return delegate;
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
};

export const delegate = async (groupId: number | string) => {
	groupId = Number(groupId);

	try {
		const contract = await getContract();
		const feeData = await contract.provider.getFeeData();
		const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
		const estimatedGasLimit = await contract.estimateGas.delegate(
			groupId,
			env.PUBLIC_SIGNER_ADDRESS
		);
		const tx = await contract.delegate(groupId, env.PUBLIC_SIGNER_ADDRESS, {
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas
		});

		const txReceipt = await tx.wait({ timeout: 4000 });
		if (txReceipt && txReceipt.status === 1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const NewDelegationEvent = parsedLogs.find((log: any) => log.name === 'NewDelegation');
			if (NewDelegationEvent) {
				const delegate = NewDelegationEvent.args.to;
				const delegater = NewDelegationEvent.args.from;
				const groupId = NewDelegationEvent.args.groupId;
				console.log(`New delegation from "${delegater}" to "${delegate} in group ${groupId}`);
			} else {
				console.warn('NewDelegation event not found in transaction logs');
			}
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error delegating', error);
	}
};

export const removeDelegation = async () => {
	try {
		const contract = await getContract();
		const feeData = await contract.provider.getFeeData();
		const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
		const estimatedGasLimit = await contract.estimateGas.removeDelegation(
			env.PUBLIC_SIGNER_ADDRESS,
			2
		);
		const tx = await contract.removeDelegation(env.PUBLIC_SIGNER_ADDRESS, 2, {
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas
		});

		const txReceipt = await tx.wait({ timeout: 4000 });
		if (txReceipt && txReceipt.status === 1) {
			console.log('Transaction successful');
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error delegating', error);
	}
};
