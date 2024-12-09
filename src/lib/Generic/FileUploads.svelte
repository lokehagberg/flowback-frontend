<script lang="ts">
	import { faUpload } from '@fortawesome/free-solid-svg-icons';
	import ImageUpload from './FileUpload.svelte';
	import { _ } from 'svelte-i18n';

	export let images: File[] = [],
		minimalist = false,
		Class = '';

	let image: File | null = null;
</script>


{#if images.length > 0}
	<div>
		{#each images as image}
			<div
				class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300"
			>
				{image.name}
			</div>
		{/each}
	</div>
{/if}

<div
	class={minimalist
		? 'inline m-auto'
		: `${Class} flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300`}
>
	{#if !minimalist}{$_('Add media')}{/if}
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
