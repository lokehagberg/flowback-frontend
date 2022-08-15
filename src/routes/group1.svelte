<script>
	import Header from '$lib/Header/Header.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
	import { faPeopleGroup } from '@fortawesome/free-solid-svg-icons/faPeopleGroup';
import Fa from 'svelte-fa/src/fa.svelte';
</script>

<Header />

<div class="relative">
	<div class="bg-red-500 h-56" />
	<div class="bg-blue-500 h-36 w-36 absolute -bottom-8 left-8" />
</div>
<div class="bg-white pt-12 flex justify-between align-middle pl-4 pr-4 pb-4">
    <h1 class="text-3xl">We hate lithuanians for no reason</h1>
    <p class="text-xl">50 members</p>
</div>

<div class="flex justify-center mt-16 ">
	<div class="flex justify-center w-2/3">
		<PollThumbnails />
	</div>

	<div>
		<div class="bg-white p-4 shadow rounded flex flex-col gap-6">
			<!-- <FaLayers size="4x" style="background: mistyrose"> -->
			<!-- <Fa icon={faPoll} /> -->
			<!-- <Fa icon={faPoll} scale={0.5} color="white" />
              </FaLayers> -->
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
					on:click={() => (window.location.href = '/pollmembers')}
				>
					Members
				</div>
			</div>
			
		</div>
	</div>
</div>
