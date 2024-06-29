<script lang="ts">
	import { faUpload } from '@fortawesome/free-solid-svg-icons';
	import ImageUpload from './ImageUpload.svelte';

	export let images: File[] = [];
	let image: File | null = null;
</script>

<div>
	<div class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300">
		Add media
		<ImageUpload
			icon={faUpload}
			bind:croppedImage={image}
			minimalist
			label=""
			iconSize="1.5x"
			disableImagePreview
			onCrop={() => {
				if (image) {
					images.push(image);
					images = images;
				}
			}}
		/>
	</div>
	<div class="flex flex-col gap-3 mt-3">
		{#each images as image}
			<div
				class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300"
			>
				{image.name}
			</div>
		{/each}
	</div>
</div>
