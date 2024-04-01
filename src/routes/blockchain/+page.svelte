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
		getPollResults,
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

   
    
    onMount(() => {
        
        // test(value); // Call test with group
});

    // function handleChange(event) {
    //     value = event.target.valueAsNumber; // Converts input string to number
    // }


    let userAddress = '';

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
</script>
<style>
    hr {
        border: 0;
        border-top: 1px solid #8a8a8a;
        margin: 20px 0;
    }
</style>

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
    <hr>
    <b>rightToVote</b>
    <div class="p-6">
        <button on:click={becomeMemberOfGroup}>Become member</button> 
    </div> 
    <div class="p-6">
        <button on:click={removeGroupMembership}>Resign as member</button> 
    </div> 
    <div class="p-6">
        <button on:click={isUserMemberInGroup}>Check if user is member of group</button> 
    </div> 
    <div class="p-6">
        <button on:click={getGroupsUserIsMemberIn}>Get groups user is member in</button> 
    </div> 
    <hr>
    <b>polls</b>
    <div class="p-6">
       
        <button on:click={createPoll}>Create poll</button> 
    </div>
    <div class="p-6">

        <button on:click={getPoll}>Get poll</button> 
    </div>
    <div class="p-6">

        <button on:click={createProposal}>Create proposal</button> 
    </div>
    <div class="p-6">

        <button on:click={getProposalsOnPoll}>Get proposals </button> 
    </div>
    <div class="p-6">

        <button on:click={getPollResults}>Get pollresult</button> 
    </div>
    <div class="p-6">

        <button on:click={vote}>vote</button> 
    </div>
    <hr>
    <b>prediction/predictionbets</b>
    <div class="p-6">

        <button on:click={createPrediction}>Create prediction</button> 
    </div>
    <div class="p-6">

        <button on:click={getPredictionsOnPoll}>Get predictions on poll</button> 
    </div>
    <div class="p-6">

        <button on:click={createPredictionBet}>Create prediction bet</button> 
    </div>
    <div class="p-6">

        <button on:click={getPredictionBets}>Get prediction bets</button> 
    </div>
    
    
    <hr>
    <b>delegations</b>
</Layout>

