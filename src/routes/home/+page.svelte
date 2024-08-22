<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	import Layout from '$lib/Generic/Layout.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import type { poll } from '$lib/Poll/interface';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import { homePolls as homePollsLimit } from '$lib/Generic/APILimits.json';
	import { becomeMemberOfGroup } from '$lib/Blockchain/javascript/rightToVote';
	import {env} from "$env/dynamic/public";
	import { goto } from '$app/navigation';

	interface Invitation {
		external: boolean;
		group: number;
		user: number;
		username: string;
		group_name: string;
		profile_image: string;
	}

	let invitations: Invitation[] = [];
	let polls: poll[] = [],
		status: StatusMessageInfo;

	onMount(async () => {
		if (env.PUBLIC_ONE_GROUP_FLOWBACK === "TRUE") goto('groups/1')

		getInvitations();
		getPolls();
	});

	const getInvitations = async () => {
		const { res, json } = await fetchRequest('GET', 'group/invites');
		invitations = json.results;
	};

	const acceptInvitation = async (id: number) => {
		const { res, json } = await fetchRequest('POST', `group/${id}/invite/accept`);

		if (!res.ok) {
			return;
		}

		invitations = invitations.filter((invite) => invite.group !== id);
		invitations = invitations;
		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === "TRUE") becomeMemberOfGroup(id);
	};

	const rejectInvitation = async (id: number) => {
		const { res, json } = await fetchRequest('POST', `group/${id}/invite/reject`);
	};

	const getPolls = async () => {
		const { res, json } = await fetchRequest('GET', `home/polls?limit=${homePollsLimit}`);
		status = statusMessageFormatter(res, json);
	};
</script>

<Layout centered>
	<ul class="w-full mt-6 flex flex-col gap-6 max-w-[700px]">
		{#each invitations as invite}
			{#if !invite.external}
				<li class="bg-white p-6 shadow rounded dark:bg-darkobject dark:text-darkmodeText">
					<span>{$_('You have been invited to')} {invite.group_name}</span>

					<div class="mt-4">
						<Button action={() => acceptInvitation(invite.group)}>{$_('Accept')}</Button>
						<Button action={() => rejectInvitation(invite.group)}>{$_('Reject')}</Button>
					</div>
				</li>
			{/if}
		{/each}
	</ul>
	<PollThumbnails infoToGet="home" Class="w-[95%] md:w-[70%] max-w-[770px] justify-center mt-6" />
</Layout>
