import {newWallet} from './newWallet.js';

export let test = () => {

	const wallet = newWallet();

	console.log('public key:', wallet.publicKey);
	console.log('private key:', wallet.privateKey);
};
