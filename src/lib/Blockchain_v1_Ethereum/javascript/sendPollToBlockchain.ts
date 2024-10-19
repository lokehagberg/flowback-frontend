require('dotenv').config({ path: '../.env' });

const contractVoteABI = require('./contractABI.json');
const contractAddress2 = '0x7386bDA1604Fd197645801216C460f6c85e4615E';
const contractVote = new ethers.Contract(contractAddress2, contractVoteABI, wallet);

async function sendPollToBlockchain(
	title:string,
	tag:string,
	group:number,
	pollStartDate:number,
	proposalEndDate:number,
	votingStartDate:number,
	delegateEndDate:number,
	endDate:number
) {
	const tx = await contractVote.createPoll(
		title,
		tag,
		group,
		pollStartDate,
		proposalEndDate,
		votingStartDate,
		delegateEndDate,
		endDate
	);

	const txReceipt = await tx.wait();

	if (txReceipt.status === 1) {
		console.log('Transaction successful');

		const logs = txReceipt.logs;

		const parsedLogs = logs.map((log: any) => contractVote.interface.parseLog(log));

		const pollCreatedEvent = parsedLogs.find((log: any) => log.name === 'PollCreated');

		if (pollCreatedEvent) {
			const pollId = pollCreatedEvent.args.pollId;
			const pollTitle = pollCreatedEvent.args.title;

			console.log('PollCreated event emitted');
			console.log('Poll Id', pollId.toString());
			console.log('Poll Title', pollTitle);
		} else {
			console.log('PollCreated event not found in the transaction logs');
		}
	} else {
		console.error('Transaction failed');
		console.log(txReceipt);
	}
}

sendPollToBlockchain('What should we have for dinner?', 'Food', 1, 2, 3, 4, 5, 6);
