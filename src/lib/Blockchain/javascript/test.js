import { becomeMemberOfGroup, delegate } from './delegationsBlockchain.ts';
import {newWallet} from './newWallet.js';

export let test = () => {

	// const wallet = newWallet();

	// console.log('public key:', wallet.publicKey);
	// console.log('private ke:', wallet.privateKey);

	// delegate(1, 1)
	becomeMemberOfGroup(1)
};
