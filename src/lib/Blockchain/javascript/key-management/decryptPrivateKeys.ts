// import CryptoJS from 'crypto-js'
const CryptoJS = require('crypto-js');

const decryptPrivateKeys = (encryptedPrivateKey: any, secretKey: any) => {
	const decryptPrivateKeys = CryptoJS.AES.decrypt(encryptedPrivateKey, secretKey).toString(
		CryptoJS.enc.Utf8
	);

	console.log('decrypted key', decryptPrivateKeys);

	return decryptPrivateKeys;
};

decryptPrivateKeys(
	'U2FsdGVkX1/pCXF1Vef+KQUNvtbvPajGRLZ9yXNQ3tw=',
	'sDIUIMXQhC601YITTLrUAoMNqcbQpEsL'
);
