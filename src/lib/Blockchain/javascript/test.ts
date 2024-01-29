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




// _isSigner: true
// ​
// _mnemonic: function _Wallet()
// ​​
// length: 0
// ​​
// name: ""
// ​​
// <prototype>: function ()
// ​
// _signingKey: function _Wallet()
// ​​
// length: 0
// ​​
// name: ""
// ​​
// <prototype>: function ()
// ​
// address: "0xfe382E9111991D04F293687053e0466721D7812c"
// ​
// provider: Object { _isProvider: true, disableCcipRead: false, anyNetwork: false, … }
// ​​
// _emitted: Object { block: -2 }
// ​​
// _events: Array []
// ​​
// _fastQueryDate: 0
// ​​
// _isProvider: true
// ​​
// _lastBlockNumber: -2
// ​​
// _maxFilterBlockRange: 10
// ​​
// _maxInternalBlockNumber: -1024
// ​​
// _network: Object { name: "sepolia", chainId: 11155111, ensAddress: null, … }
// ​​
// _nextId: 42
// ​​
// _pollingInterval: 4000
// ​​
// anyNetwork: false
// ​​
// apiKey: "84842078b09946638c03157f83405213"
// ​​
// connection: Object { allowGzip: true, url: "https://sepolia.infura.io/v3/84842078b09946638c03157f83405213", throttleCallback: throttleCallback(attempt, url)
//  }
// ​​
// disableCcipRead: false
// ​​
// formatter: Object { formats: {…} }
// ​​
// projectId: "84842078b09946638c03157f83405213"
// ​​
// projectSecret: null