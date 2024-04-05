import { ethers } from 'ethers';
import contractABI from './contractABI.json';

// interface Window {
// 	ethereum?: import('ethers').providers.ExternalProvider;
//   }
  
// 	async function getUser() {
// 	  if (window.ethereum) {
// 		await window.ethereum.request({ method: 'eth_requestAccounts' });
// 		const provider = new ethers.providers.Web3Provider(window.ethereum);
// 		const signer = provider.getSigner();
// 		const address = await signer.getAddress();
// 		console.log('Address:', address);
// 		//console.log("GetCode:", await provider.getCode("0xf43205cD2E7Ab7416D73cCcFC30cD5d980c9A31a"));
  
// 		return signer;
// 	  } else {
// 		console.log('MetaMask is not available');
// 		throw new Error('MetaMask is not available');
// 	  }
// 	}
	
// 	const getContract = async () => {
// 	  const signer = await getUser();
// 	  const contractAddress = '0xE05D980037dae23116c2Af375D5caF2d7d5D55A6'; //use this address
// 	  return new ethers.Contract(contractAddress, contractABI, signer);
// 	};

const getContract = (privateKey:string) => {
	
	const provider = new ethers.providers.InfuraProvider('sepolia', import.meta.env.INFURA_API_KEY);
	const wallet = new ethers.Wallet(privateKey, provider);
	const contractAddress = '0xf43205cD2E7Ab7416D73cCcFC30cD5d980c9A31a';
	return new ethers.Contract(contractAddress, contractABI, wallet);
};

export const delegate = async (groupId: number, reciever: any, privateKey:string) => {
	const contract = getContract(privateKey);
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

//becomeDelegate(1);
//delegate(1,"adress");
