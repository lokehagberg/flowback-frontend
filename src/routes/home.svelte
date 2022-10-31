<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import type { poll } from '$lib/Poll/interface';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	interface Invitation {
		external: boolean;
		group: number;
		profile_image: File | null;
		user: number;
		username: string;
	}

	let invitations: Invitation[] = [];
	let polls: poll[] = [];

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
	};
</script>

<Layout centering={true}>
	<ul class="mt-6">
		{#each invitations as invite}
			<li class="bg-white p-6 shadow rounded">
				<span>You have been invited to NAME</span>
				<ButtonPrimary action={() => acceptInvitation(invite.group)}>Accept</ButtonPrimary>
				<ButtonPrimary action={() => rejectInvitation(invite.group)}>Reject</ButtonPrimary>
			</li>
		{/each}
	</ul>

	<PollThumbnails infoToGet="home" Class="sm:w-5/6 md:w-2/3 justify-center" />
</Layout>
