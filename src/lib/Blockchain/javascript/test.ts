//@ts-ignore
import { becomeMemberOfGroup, delegate } from './delegationsBlockchain.ts';
//@ts-ignore
import { newWallet } from './newWallet.ts';

export let test = () => {
	// const wallet = newWallet();

	// console.log('public key:', wallet.publicKey);
	// console.log('private ke:', wallet.privateKey);

	// delegate(1, 1)
	becomeMemberOfGroup(1);
};
