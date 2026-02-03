<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import { becomeMemberOfGroup } from '$lib/Blockchain_v1_Ethereum/javascript/rightToVote';
	import { env } from '$env/dynamic/public';
	import { goto } from '$app/navigation';
	import PollThreadThumbnails from '$lib/Poll/PollThreadThumbnails.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { idfy } from '$lib/Generic/GenericFunctions2';
	import { InfoToGet } from '$lib/Poll/interface';

	interface Invitation {
		external: boolean;
		group: number;
		user: number;
		username: string;
		group_name: string;
		profile_image: string;
	}

	let invitations: Invitation[] = [];

	onMount(async () => {
		if (env.PUBLIC_ONE_GROUP_FLOWBACK === 'TRUE') goto('groups/1');

		getInvitations();
	});

	const getInvitations = async () => {
		const { res, json } = await fetchRequest('GET', 'group/invites');
		invitations = json?.results;
	};

	const acceptInvitation = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${id}/invite/accept`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not accept invitation',
				success: false
			});
			return;
		}

		ErrorHandlerStore.set({ message: 'Joined Group', success: true });
		invitations = invitations.filter((invite) => invite.group !== id);
		invitations = invitations;
		if (env.PUBLIC_BLOCKCHAIN_INTEGRATION === 'TRUE') becomeMemberOfGroup(id);
	};

	const rejectInvitation = async (id: number) => {
		const { res, json } = await fetchRequest(
			'POST',
			`group/${id}/invite/reject`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not reject invitation',
				success: false
			});
			return;
		}
		invitations = invitations.filter((invite) => invite.group !== id);
		invitations = invitations;
	};
</script>

<!-- Displays all the invites a user has (which for now is on the home page) -->
<Layout centered>
	{#if invitations && invitations.length > 0}
		<ul class="w-full mt-6 flex flex-col gap-6 max-w-[700px]">
			{#each invitations as invite}
				{#if !invite?.external}
					<li
						id={`invite-${idfy(invite.group_name)}`}
						class="bg-white p-6 shadow rounded dark:bg-darkobject dark:text-darkmodeText"
					>
						<span>{$_('You have been invited to')} {invite.group_name}</span>

						<div class="mt-4">
							<Button onClick={() => acceptInvitation(invite.group)}
								>{$_('Accept')}</Button
							>
							<Button onClick={() => rejectInvitation(invite.group)}
								>{$_('Reject')}</Button
							>
						</div>
					</li>
				{/if}
			{/each}
		</ul>
	{/if}
	<PollThreadThumbnails
		infoToGet={InfoToGet.home}
		Class="w-[95%] md:w-[70%] max-w-[770px] justify-center mt-6"
	/>
</Layout>
