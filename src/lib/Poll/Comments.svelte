<script>
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import HeaderIcon from '$lib/Header/HeaderIcon.svelte';
</script>

<div>
	<h1 class="text-left text-2xl">Comments</h1>
	<form class="mt-4">
		<!-- <TextArea type="field" label="Comment" /> -->
		<ButtonPrimary>Submit</ButtonPrimary>
	</form>

	<div class="flex flex-col gap-4 mt-6">
		<div class="border border-gray-400 p-4">
			<div class="flex gap-3">
				<div class="w-6 h-6 bg-red-600" />
				<div>Emil</div>
			</div>
			<div>I will tweet a racial slur</div>
			<div class="flex"><HeaderIcon /> Reply</div>
		</div>
		<div class="border border-gray-400 p-4 ml-4">
			<div>Nerd</div>
			<div>
				Nooo don't do it you have a family and you're so sexy haha Lorem ipsum dolor sit amet
				consectetur adipisicing elit. Unde quisquam minus vel non eaque, exercitationem, sapiente
				animi cumque et officiis eveniet sequi hic velit excepturi ratione laudantium recusandae
				reprehenderit consequatur?
			</div>
		</div>
	</div>
</div>
