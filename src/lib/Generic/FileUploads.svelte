<script lang="ts">
	import { faUpload } from '@fortawesome/free-solid-svg-icons';
	import ImageUpload from './ImageUpload.svelte';

	export let images: File[] = [],
		minimalist = false;
	let image: File | null = null;
</script>

<div>
	{#each images as image}
		<div class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300">
			{image.name}
		</div>
	{/each}
</div>
<div
	class={minimalist
		? 'inline'
		: `flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300`}
>
	{#if !minimalist}Add media{/if}
	<ImageUpload
		icon={faUpload}
		bind:croppedImage={image}
		minimalist
		Class="!inline"
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
