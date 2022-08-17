<script lang="ts">
	import GroupHeader from '../../lib/Group/GroupHeader.svelte';
	import Header from '$lib/Header/Header.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import { faPeopleGroup } from '@fortawesome/free-solid-svg-icons/faPeopleGroup';
	import Fa from 'svelte-fa/src/fa.svelte';
	import Members from '$lib/Group/Members.svelte';
	import {selectablePages} from '$lib/Group/interface'

	let selectedPage: selectablePages = selectablePages.pollthumbnails;
</script>

<Header />

<GroupHeader bind:selectedPage/>

<div class="flex justify-center mt-16 gap-16">
	<div class="flex justify-center w-2/3">
		{#if selectedPage === 'pollthumbnails'}
			<PollThumbnails />
		{:else if selectedPage === 'members'}
			<Members />
		{/if}
	</div>

	<div>
		<div class="bg-white p-4 shadow rounded flex flex-col gap-6">
			<div class="flex item-center items-center">
				<Fa icon={faPoll} />
				<div
					class="ml-2 cursor-pointer hover:underline"
					on:click={() => (window.location.href = '/createpoll')}
				>
					Create a poll
				</div>
			</div>
			<div class="flex item-center items-center">
				<Fa icon={faPeopleGroup} />
				<div
					class="ml-2 cursor-pointer hover:underline"
					on:click={() => (selectedPage = selectablePages.members)}
				>
					Members
				</div>
			</div>
		</div>
	</div>
</div>
