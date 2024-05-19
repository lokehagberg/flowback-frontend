<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import { test } from '$lib/Blockchain/javascript/test';
	import Button from '$lib/Generic/Button.svelte';
	import { onMount } from 'svelte';
	import {
		createPoll,
		getPoll,
		createProposal,
		getProposalsOnPoll,
		vote,
		getPollResults
	} from '$lib/Blockchain/javascript/pollsBlockchain';
	import {
		createPrediction,
		getPredictionsOnPoll,
		createPredictionBet,
		getPredictionBets
	} from '$lib/Blockchain/javascript/predictionsBlockchain';
	import {
		becomeMemberOfGroup,
		removeGroupMembership,
		isUserMemberInGroup,
		getGroupsUserIsMemberIn
	} from '$lib/Blockchain/javascript/rightToVote';

	let userAddress = '';
	let id = '';
	let groupId = '';
	let pollId = '';
	let proposalId = '';

	async function connectWallet() {
		if (typeof window.ethereum !== 'undefined') {
			try {
				const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
				userAddress = accounts[0];
			} catch (error) {
				console.error('Error connecting to MetaMask', error);
			}
		} else {
			console.error('MetaMask is not installed!');
		}
	}

	async function handleBecomeMember() {
		try {
			await becomeMemberOfGroup(groupId);
		} catch (error) {
			console.error('Error becoming member of group', error);
		}
	}

	async function handleRemoveMembership() {
		try {
			await removeGroupMembership();
		} catch (error) {
			console.error('Error removing membership from group', error);
		}
	}

	async function handleCheckMembership() {
		try {
			const isMember = await isUserMemberInGroup();
			console.log(`User is ${isMember ? '' : 'not '}a member of the group`);
		} catch (error) {
			console.error('Error checking membership', error);
		}
	}

	async function handleGetGroupsUserIsMemberIn() {
		try {
			const groups = await getGroupsUserIsMemberIn();
			console.log('Groups user is member in:', groups);
		} catch (error) {
			console.error('Error getting groups user is member in', error);
		}
	}

	async function handleCreatePoll() {
		try {
			await createPoll(groupId);
		} catch (error) {
			console.error('Error creating poll', error);
		}
	}

	async function handleGetPoll() {
		try {
			const poll = await getPoll(id);
			console.log('Poll:', poll);
		} catch (error) {
			console.error('Error getting poll', error);
		}
	}

	async function handleCreateProposal() {
		try {
			await createProposal(pollId);
		} catch (error) {
			console.error('Error creating proposal', error);
		}
	}

	async function handleGetProposalsOnPoll() {
		try {
			const proposals = await getProposalsOnPoll(pollId);
			console.log('Proposals on poll:', proposals);
		} catch (error) {
			console.error('Error getting proposals on poll', error);
		}
	}

	async function handleGetPollResults() {
		try {
			const results = await getPollResults(id);
			console.log('Poll results:', results);
		} catch (error) {
			console.error('Error getting poll results', error);
		}
	}

	async function handleVote() {
		try {
			await vote(pollId, proposalId);
		} catch (error) {
			console.error('Error voting', error);
		}
	}

	async function handleCreatePrediction() {
		try {
			await createPrediction(id, 1);
		} catch (error) {
			console.error('Error creating prediction', error);
		}
	}

	async function handleGetPredictionsOnPoll() {
		try {
			const predictions = await getPredictionsOnPoll(id, 1);
			console.log('Predictions on poll:', predictions);
		} catch (error) {
			console.error('Error getting predictions on poll', error);
		}
	}

	async function handleCreatePredictionBet() {
		try {
			await createPredictionBet(id, 1);
		} catch (error) {
			console.error('Error creating prediction bet', error);
		}
	}

	async function handleGetPredictionBets() {
		try {
			const bets = await getPredictionBets(id, 1);
			console.log('Prediction bets:', bets);
		} catch (error) {
			console.error('Error getting prediction bets', error);
		}
	}
</script>

<Layout>
	<button on:click={connectWallet}>
		{#if userAddress}
			Connected: {userAddress}
		{:else}
			Connect Wallet
		{/if}
	</button>

	{#if userAddress}
		<p>Wallet Address: {userAddress}</p>
	{/if}
	<hr />
	<b>rightToVote</b>
	<div class="p-6">
		<input type="text" bind:value={groupId} placeholder="Enter Group ID">
		<button on:click={handleBecomeMember}>Become member</button>
	</div>
	<div class="p-6">
		<button on:click={handleRemoveMembership}>Resign as member</button>
	</div>
	<div class="p-6">
		<button on:click={handleCheckMembership}>Check if user is member of group</button>
	</div>
	<div class="p-6">
		<button on:click={handleGetGroupsUserIsMemberIn}>Get groups user is member in</button>
	</div>
	<hr />
	<b>polls</b>
	<div class="p-6">
		<input type="text" bind:value={groupId} placeholder="Enter Group ID">
		<button on:click={handleCreatePoll}>Create poll</button>
	</div>
	<div class="p-6">
		<button on:click={handleGetPoll}>Get poll</button>
	</div>
	<div class="p-6">
		<input type="text" bind:value={pollId} placeholder="Enter Poll Id">
		<button on:click={handleCreateProposal}>Create proposal</button>
	</div>
	<div class="p-6">
		<input type="text" bind:value={pollId} placeholder="Enter Poll Id">
		<button on:click={handleGetProposalsOnPoll}>Get proposals </button>
	</div>
	<div class="p-6">
		<button on:click={handleGetPollResults}>Get poll results</button>
	</div>
	<div class="p-6">
		<input type="text" bind:value={pollId} placeholder="Enter Poll Id">
		<input type="text" bind:value={proposalId} placeholder="Enter Proposal Id">
		<button on:click={handleVote}>Vote</button>
	</div>
	<hr />
	<b>prediction/prediction bets</b>
	<div class="p-6">
		<button on:click={handleCreatePrediction}>Create prediction</button>
	</div>
	<div class="p-6">
		<button on:click={handleGetPredictionsOnPoll}>Get predictions on poll</button>
	</div>
	<div class="p-6">
		<button on:click={handleCreatePredictionBet}>Create prediction bet</button>
	</div>
	<div class="p-6">
		<button on:click={handleGetPredictionBets}>Get prediction bets</button>
	</div>

	<hr />
	<b>delegations</b>
</Layout>

<style>
	hr {
		border: 0;
		border-top: 1px solid #8a8a8a;
		margin: 20px 0;
	}
</style>