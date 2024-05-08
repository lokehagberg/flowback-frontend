import { ethers } from 'ethers';
import contractABI from './contractABI.json';
import { estimateGas } from 'web3/lib/commonjs/eth.exports';

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
	
}