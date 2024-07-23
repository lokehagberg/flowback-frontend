import { ethers } from 'ethers';
import contractABI from './contractABI.json';

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
	const contractAddress = '0xDeE004347e6C7D2c7B2E2e26ef9Cdab1B1838F52'; //use this address
	return new ethers.Contract(contractAddress, contractABI, signer);
};

export const createPrediction = async (pollId: number, propId: number, prediction:string) => {
	const contract = await getContract();
	const { provider } = await getContract();
	const feeData = await provider.getFeeData();
	const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
	const estimatedGasLimit = await contract.estimateGas.createPrediction(pollId, propId, prediction);
	const tx = await contract.createPrediction(
		pollId, //pollid
		propId, //proposalid
		prediction, //prediction
		{
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas
		}
	);

	try {
		const txReceipt = await tx.wait({ timeout: 40000 });
		if (txReceipt && txReceipt.status === 1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const PredictionCreatedEvent = parsedLogs.find(
				(log: any) => log.name === 'PredictionCreated'
			);
			if (PredictionCreatedEvent) {
				const pollId = PredictionCreatedEvent.args.pollId;
				const proposalId = PredictionCreatedEvent.args.proposalId;
				const predictionId = PredictionCreatedEvent.args.predictionId;
				const prediction = PredictionCreatedEvent.args.prediction;
				console.log(
					`Prediction with id ${predictionId} is now created on pollid ${pollId}, proposal id ${proposalId}! PREDICTION: "${prediction}"`
				);

				return predictionId;
			}
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error waiting for transaction:', error);
	}
};
export const getPredictionsOnPoll = async (id: number, propId: number) => {
	const contract = await getContract();
	const tx = await contract.getPredictions(id, propId); //pollid, proposalid
	console.log(`PREDICTIONS ON POLLID ${tx[0].pollId}, PROPOSALID ${tx[0].proposalId}`);
	tx.map((prediction: any) =>
		console.log(`Prediction with id ${prediction.predictionId}: "${prediction.prediction}"`)
	);
};

//-------------------------------------------------------------
//-------------------PREDICTIONBETS----------------------------
//-------------------------------------------------------------

export const createPredictionBet = async (pollId: number, predId: number, score:number) => {
	const contract = await getContract();
	const { provider } = await getContract();
	const feeData = await provider.getFeeData();
	const maxPriorityFeePerGas = feeData.maxPriorityFeePerGas;
	const estimatedGasLimit = await contract.estimateGas.placePredictionBet(
		pollId,
		1,
		predId,
		score,
		true
	);
	const tx = await contract.placePredictionBet(
		pollId, //pollid
		1, //proposalid
		predId, //predictionid
		9, //likelihood
		true, //bet

		{
			gasLimit: estimatedGasLimit,
			maxPriorityFeePerGas: maxPriorityFeePerGas
		}
	);

	try {
		const txReceipt = await tx.wait({ timeout: 40000 });
		if (txReceipt && txReceipt.status === 1) {
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const PredictionBetCreatedEvent = parsedLogs.find(
				(log: any) => log.name === 'PredictionBetCreated'
			);
			if (PredictionBetCreatedEvent) {
				const predictionBet = PredictionBetCreatedEvent.args.bet;
				const likelihood = PredictionBetCreatedEvent.args.likelihood;
				const predictionId = PredictionBetCreatedEvent.args.predictionId;
				console.log(
					`Placed bet: ${likelihood}% sure that prediction id ${predictionId} will be ${predictionBet}`
				);
			}
		} else {
			console.warn('Transaction might have failed');
			console.log(txReceipt);
		}
	} catch (error) {
		console.error('Error waiting for transaction:', error);
	}
};
export const getPredictionBets = async (id: number, predId: number) => {
	const contract = await getContract();
	const tx = await contract.getPredictionBets(id, 1, predId); //pollid, proposalid,predictionId
	console.log(tx);
	console.log(
		`PREDICTIONBETS ON POLLID ${tx[0].pollId}, PROPOSALID ${tx[0].proposalId}, PREDICTIONID ${tx[0].predictionId}`
	);
	tx.map((predictionbet: any) =>
		console.log(`Predictionbet: ${predictionbet.likelihood}% sure to be ${predictionbet.bet}`)
	);
};
