<script lang="ts">
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import CropperModal from './Cropper/CropperModal.svelte';

	export let croppedImage: File | null = null,
		label: string,
		isProfile = false,
		icon: any,
		Class = '',
		iconSize = '5x',
		imageString: string | null = null,
		minimalist = false,
		onCrop = () => {},
		disableImagePreview = false,
		disableCropping = false;
	export let acceptTypes = ".jpg, .jpeg, .png, .pdf, .txt";

	let fileinput: HTMLInputElement, currentlyCropping: boolean;

	const onFileSelected = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		if (files.length > 0) {
			croppedImage = files[0];
			imageString = URL.createObjectURL(croppedImage);
			if (!disableCropping && isImageFile(croppedImage.name)) {
				currentlyCropping = true;
			} else {
				onCrop();
			}
		}
	};

	const isImageFile = (fileName: string): boolean => {
		const ext = fileName.split('.').pop()?.toLowerCase();
		return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext || '');
	};

	$: if (imageString !== null) {
		// currentlyCropping = true;
	}
</script>

<div class={`image-upload ${Class}`}>
	{#if label}
		<h1 class="text-left text-sm w-full">{$_(label)}</h1>
	{/if}
	{#if imageString && !disableImagePreview}
		<img
			id="image"
			class={`${isProfile ? 'rounded-full' : 'cover'} avatar`}
			alt={$_(label)}
			src={imageString || "/placeholder.svg"}
		/>
	{/if}

	<button
		class="cursor-pointer"
		on:click|preventDefault={() => {
			fileinput.click();
		}}
	>
		<Fa {icon} size={iconSize} />
	</button>
	<button
		on:click|preventDefault={() => {
			fileinput.click();
		}}
	>
		{#if !minimalist}
			{$_('Choose Image')}
		{/if}
	</button>
	<input
		style="display:none"
		type="file"
		accept={acceptTypes}
		on:change={(e) => onFileSelected(e)}
		bind:this={fileinput}
	/>
</div>

{#if currentlyCropping}
	<CropperModal
		confirmAction={() => {
			currentlyCropping = false;
			onCrop();
		}}
		cancelAction={() => {
			currentlyCropping = false;
		}}
		bind:croppedImage={imageString}
		bind:currentlyCroppingProfile={isProfile}
		bind:image={imageString}
	/>
{/if}

<style>
	.image-upload {
		display: flex;
		align-items: center;
		justify-content: center;
		flex-flow: column;
	}

	.upload {
		display: flex;
		height: 50px;
		width: 50px;
		cursor: pointer;
	}

	.avatar {
		display: flex;
		height: 10rem;
		width: 10rem;
	}

	.cover {
		width: 100%;
	}
</style>
