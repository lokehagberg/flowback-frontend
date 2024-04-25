<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	import CropperModal from './Cropper/CropperModal.svelte';

	export let croppedImage: File | null = null,
		label: string,
		isCover = false,
		icon: any,
		Class = '',
		iconSize = '5x',
		imageString: string;

	let fileinput: HTMLInputElement, currentlyCropping: boolean;

	const onFileSelected = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		croppedImage = files[0];
		currentlyCropping = true;
	};

	$: if (croppedImage) {
		console.log(croppedImage, typeof croppedImage)
		imageString = URL.createObjectURL(croppedImage);
	} 
</script>

<div class={`image-upload ${Class}`}>
	<h1 class="text-left text-sm w-full">{$_(label)}</h1>

	{#if croppedImage}
		<img
			id="image"
			class={`${isCover ? 'cover' : ''} avatar`}
			alt={$_(label)}
			src={imageString}
		/>
	{:else}
		<!-- <img
			class="avatar"
			src="https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png"
			alt=""
		/> -->
		<Fa {icon} size={iconSize} class="mt-6" />
	{/if}
	<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
	<img
		class="upload mt-4"
		src="https://static.thenounproject.com/png/625182-200.png"
		alt=""
		on:click={() => {
			fileinput.click();
		}}
		on:keydown
	/>
	<!-- svelte-ignore a11y-no-static-element-interactions -->
	<div
		class="chan"
		on:click={() => {
			fileinput.click();
		}}
		on:keydown
	>
		{$_('Choose Image')}
	</div>
	<input
		style="display:none"
		type="file"
		accept=".jpg, .jpeg, .png"
		on:change={(e) => onFileSelected(e)}
		bind:this={fileinput}
	/>
</div>

{#if currentlyCropping}
	<CropperModal
		confirmAction={() => {
			currentlyCropping = false;
		}}
		cancelAction={() => {
			currentlyCropping = false;
		}}
		bind:croppedImage={imageString}
		bind:currentlyCroppingProfile={currentlyCropping}
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
