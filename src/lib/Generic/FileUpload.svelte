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
		shouldCrop: boolean = true,
		minimalist = false,
		onCrop = () => {},
		disableImagePreview = false,
		disableCropping = false;

	let fileinput: HTMLInputElement, currentlyCropping: boolean;

	const onFileSelected = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		croppedImage = files[0];
		imageString = URL.createObjectURL(croppedImage);
		if (disableCropping) currentlyCropping = true;
		else onCrop();
	};
</script>

<div class={`image-upload ${Class}`}>
	<h1 class="text-left text-sm w-full">{$_(label)}</h1>

	{#if imageString && !disableImagePreview}
		<img
			id="image"
			class={`${isProfile ? 'rounded-full' : 'cover'} avatar`}
			alt={$_(label)}
			src={imageString}
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
		accept=".jpg, .jpeg, .png"
		on:change={(e) => onFileSelected(e)}
		bind:this={fileinput}
	/>
</div>

{#if currentlyCropping && shouldCrop}
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
