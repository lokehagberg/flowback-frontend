<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Layout from '$lib/Generic/Layout.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';
	import type { poll } from '$lib/Poll/interface';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	interface Invitation {
		external: boolean;
		group: number;
		user: number;
		username: string;
		group_name:string;
		profile_image:string;
	}

	let invitations: Invitation[] = [];
	let polls: poll[] = [],
		status: StatusMessageInfo;

	onMount(async () => {
		getInvitations();
		getPolls();
	});

	const getInvitations = async () => {
		const { res, json } = await fetchRequest('GET', 'group/invites');
		invitations = json.results;
	};

	const acceptInvitation = async (id: number) => {
		console.log(id);
		const { res, json } = await fetchRequest('POST', `group/${id}/invite/accept`);
	};

	const rejectInvitation = async (id: number) => {
		const { res, json } = await fetchRequest('POST', `group/${id}/invite/reject`);
	};

	const getPolls = async () => {
		const { res, json } = await fetchRequest('GET', 'home/polls?limit=30');
		status = statusMessageFormatter(res, json);
	};
</script>

<Layout centering={true}>
	<!-- <StatusMessage Class={`${status?.success && "invisible"}`} bind:status /> -->
	<ul class="mt-6 flex flex-col gap-6">
		<!-- {#if import.meta.env.MODE === 'DEV'} -->
			{#each invitations as invite}
				<li class="bg-white p-6 shadow rounded">
					<span>You have been invited to {invite.group_name}</span>
					<ButtonPrimary action={() => acceptInvitation(invite.group)}>Accept</ButtonPrimary>
					<ButtonPrimary action={() => rejectInvitation(invite.group)}>Reject</ButtonPrimary>
				</li>
			{/each}
		<!-- {/if} -->
	</ul>
	<PollThumbnails infoToGet="home" Class="sm:w-full md:w-[44%] md:max-w-[600px] justify-center mt-6" />
</Layout>
