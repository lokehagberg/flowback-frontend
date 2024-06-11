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
		const address = await signer.getAddress();
		console.log('Address:', address);

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

export const createPoll = async (groupId: number, title: string) => {
	const contract = await getContract();
	const nowInSeconds = Math.floor(Date.now() / 1000);
	const oneDayInSeconds = 24 * 60 * 60;
	try {
		const tx = await contract.createPoll(
			title,
			'tag',
			groupId, //group
			nowInSeconds, //pollstartdate
			nowInSeconds + oneDayInSeconds, //proposalenddate
			nowInSeconds + 2 * oneDayInSeconds, //votingstartdate
			nowInSeconds + 3 * oneDayInSeconds, //delegateenddate
			nowInSeconds + 4 * oneDayInSeconds //enddate
		);

		const txReceipt = await tx.wait({ timeout: 40000 }).catch((error: any) => {
			console.error('Error waiting for transaction:', error);
		});

		if (txReceipt && txReceipt.status === 1) {
			console.log('Transaction successful');
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const pollCreatedEvents = parsedLogs.filter((log: any) => log.name === 'PollCreated');
			const PollCreatedEvent = pollCreatedEvents.length > 0 ? pollCreatedEvents[0] : undefined;

			console.log(PollCreatedEvent);
			if (PollCreatedEvent) {
				const pollId = parseInt(PollCreatedEvent.args.pollId);
				const title = PollCreatedEvent.args.title;
				console.log(`Poll created with title ${title} and id ${pollId}`);
				return pollId
			}
		}
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};

export const getPoll = async (id: number) => {
	const contract = await getContract();
	try {
		const tx = await contract.getPoll(id);
		console.log(`Poll with id ${tx.pollId}:`);
		console.log(`Title: ${tx.title}`);
		console.log(`Tag: ${tx.tag}`);
		console.log(`Startdate: ${tx.pollStartDate}`);
		console.log(`Voting date: ${tx.votingStartDate}`);
		console.log(`Enddate: ${tx.endDate}`);
		console.log(`Proposalcount: ${tx.proposalCount}`);

		//delegateEndDate, group, proposalEndDate
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};
export const createProposal = async (_pollId: number) => {
	const contract = await getContract();
	try {
		const tx = await contract.addProposal(
			_pollId, //pollid
			'description' //description
		);

		const txReceipt = await tx.wait({ timeout: 40000 }).catch((error: any) => {
			console.error('Error waiting for transaction:', error);
		});

		if (txReceipt && txReceipt.status === 1) {
			console.log('Transaction successful');
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const ProposalCreatedEvent = parsedLogs.find((log: any) => log.name === 'ProposalAdded');
			if (ProposalCreatedEvent) {
				const pollId = parseInt(ProposalCreatedEvent.args.pollId);
				const proposalId = ProposalCreatedEvent.args.proposalId;
				const description = ProposalCreatedEvent.args.description;
				console.log(
					`Proposal with id ${proposalId} created on poll with id ${pollId}: PROPOSAL: ${description}`
				);
				return Number(proposalId)
			}
		}
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};
export const getProposalsOnPoll = async (id: number) => {
	const contract = await getContract();
	try {
		const tx = await contract.getProposals(id);
		console.log(tx);
		console.log('PROPOSALS ON POLLID ', id); //change when inputs is done
		tx.forEach((element: any) => {
			console.log(
				`Proposal id ${element.proposalId}: "${element.description}" votes: ${element.voteCount}`
			);
		});
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};
export const getPollResults = async (id: number) => {
	const contract = await getContract();
	try {
		const tx = await contract.getPollResults(id);
		console.log(tx);
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};

export const vote = async (_pollId: number, _proposalId: number) => {
	const contract = await getContract();
	try {
		const tx = await contract.vote(
			_pollId, //pollid
			_proposalId //proposalid
		);

		const txReceipt = await tx.wait({ timeout: 40000 }).catch((error: any) => {
			console.error('Error waiting for transaction:', error);
		});

		if (txReceipt && txReceipt.status === 1) {
			console.log('Transaction successful');
			const logs = txReceipt.logs;
			const parsedLogs = logs.map((log: any) => contract.interface.parseLog(log));
			const VoteSubmittedEvent = parsedLogs.find((log: any) => log.name === 'VoteSubmitted');
			if (VoteSubmittedEvent) {
				console.log(VoteSubmittedEvent.args);
				const pollId = parseInt(VoteSubmittedEvent.args.pollId);
				const voter = VoteSubmittedEvent.args.voter;
				const votesForProposal = VoteSubmittedEvent.args.votesForProposal;
				console.log(
					`Vote has been cast on a proposal on poll with id ${pollId} by voter: ${voter}, votes for that proposal is now ${votesForProposal}`
				);
			}
		}
	} catch (error) {
		if (error instanceof Error) {
			console.error('Error waiting for transaction:', error.message);
		} else {
			console.error('An unexpected error occurred:', error);
		}
	}
};
