<script>
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
	import DefaultPFP from '$lib/assets/Default_pfp.png';

	const sendComment = () => {};
</script>

<div class="mt-6">
	<h1 class="text-left text-2xl">Comments</h1>
	<form class="mt-4" on:submit|preventDefault={sendComment}>
		<TextArea label="Comment" required={true}/>
		<!-- <textarea></textarea> -->
		<!-- <TextArea type="field" label="Comment" /> -->
		<ButtonPrimary className="mt-4" type="submit">Submit</ButtonPrimary>
	</form>

	<div class="flex flex-col gap-4 mt-6">
		<div class="border border-gray-400 p-4">
			<div class="flex gap-3">
				<img class="w-8 h-8 rounded-full" src={DefaultPFP} alt="default pfp"/>
				<div>Emil</div>
			</div>
			<div>Bike paths are cool, based and epic!</div>
			<!-- <div class="flex"><HeaderIcon /> Reply</div> -->
		</div>
		<div class="border border-gray-400 p-4 ml-4">
			<div class="flex gap-3">
				<img class="w-8 h-8 rounded-full" src={DefaultPFP} alt="default pfp"/>
				<div>Nerd</div>
			</div>			<div>
				I disagree
			</div>
		</div>
	</div>
</div>
