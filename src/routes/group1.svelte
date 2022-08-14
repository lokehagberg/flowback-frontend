<script>
	import Header from '$lib/Header/Header.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import PollThumbnails from '$lib/Poll/PollThumbnails.svelte';
	import { faPoll } from '@fortawesome/free-solid-svg-icons/faPoll';
</script>

<Header />

<div class="flex justify-center mt-16 ">
	<div class="flex justify-center w-2/3">
		<PollThumbnails />
	</div>

	<div>
		<div class="bg-white p-4 shadow rounded">
			<!-- <FaLayers size="4x" style="background: mistyrose"> -->
			<!-- <Fa icon={faPoll} /> -->
			<!-- <Fa icon={faPoll} scale={0.5} color="white" />
              </FaLayers> -->
			<div>
				<HeaderIcon icon={faPoll} />
				<div class="mt-2 cursor-pointer hover:underline" on:click={() => window.location.href = "/createpoll"}>Create a poll</div>
			</div>
			<div class="mt-6">Members</div>
		</div>
	</div>
</div>
