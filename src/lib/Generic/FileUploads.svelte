<script lang="ts">
	import { faUpload, faTimes, faPlus } from '@fortawesome/free-solid-svg-icons';
	import ImageUpload from './FileUpload.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';

	export let images: File[] = [],
		minimalist = false,
		Class = '';

	let image: File | null = null;

	const removeFile = (index: number) => {
		images.splice(index, 1);
		images = images;
	};
</script>


{#if images.length > 0}
	<div>
		{#each images as image, i}
			<div
				class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300"
			>
				{image.name}
				<button 
					class="ml-2 text-red-500 hover:text-red-700" 
					on:click={() => removeFile(i)}
					type="button"
				>
					<Fa icon={faTimes} />
				</button>
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
		icon={faPlus}
		bind:croppedImage={image}
		minimalist
		Class="!inline"
		label=""
		iconSize="1.2x"
		disableImagePreview
		onCrop={() => {
			if (image) {
				images.push(image);
				images = images;
			}
		}}
	/>
</div>
