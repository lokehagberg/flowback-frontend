//@ts-ignore
import { becomeMemberOfGroup, delegate } from './delegationsBlockchain.ts';
//@ts-ignore
import { newWallet } from './newWallet.ts';

export let test = async () => {
	const wallet = await newWallet();
	

	// console.log('public key:', wallet.publicKey);
	// console.log('private ke:', wallet.privateKey);

	becomeMemberOfGroup(1, wallet.privateKey);
	// delegate(1, 1)
};

