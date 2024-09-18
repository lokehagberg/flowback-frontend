<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import CropperModal from './Cropper/CropperModal.svelte';
	import { faUpload } from '@fortawesome/free-solid-svg-icons';

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
		disableImagePreview = false;

	let fileinput: HTMLInputElement, currentlyCropping: boolean;

	const onFileSelected = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		croppedImage = files[0];
		imageString = URL.createObjectURL(croppedImage);
		currentlyCropping = true;
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
	{:else if !minimalist}
		<Fa {icon} size={iconSize} class="mt-6" />
	{/if}
	<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div
		class="cursor-pointer"
		on:click={() => {
			fileinput.click();
		}}
		on:keydown
	>
		<Fa {icon} size={iconSize} />
	</div>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div
		on:click={() => {
			fileinput.click();
		}}
		on:keydown
	>
		{#if !minimalist}
			{$_('Choose Image')}
		{/if}
	</div>
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
