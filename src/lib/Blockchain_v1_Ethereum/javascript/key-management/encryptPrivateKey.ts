const generateSecretKeyPackage = require('./generateSecretKey');

function encryptPrivateKey(privateKeyToEncrypt: any) {
	const privateKey = privateKeyToEncrypt;
	const secretKey = generateSecretKeyPackage();

	const encryptedPrivateKey = CryptoJS.AES.encrypt(privateKey, secretKey).toString();

	console.log('encrypted key', encryptedPrivateKey);
}

encryptPrivateKey('0xewoirdkfpw8fd');
