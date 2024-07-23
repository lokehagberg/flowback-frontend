<script lang="ts">
	import Cropper from 'svelte-easy-crop';
	import Button from '../Button.svelte';
	import getCroppedImg from './canvasUtils';
	import { _ } from 'svelte-i18n';

	let crop = { x: 0, y: 0 },
		zoom = 1,
		pixelCrop: any;

	export let image: string | null,
		cancelAction = () => {},
		confirmAction = () => {},
		croppedImage: any,
		currentlyCroppingProfile: boolean;

	const previewCrop = (e: any) => {
		pixelCrop = e.detail.pixels;
	};

	const handleCrop = async () => {
		croppedImage = await getCroppedImg(image, pixelCrop);

		const imageToSend = await fetch(croppedImage).then((res) => res.blob());

		confirmAction();
	};
</script>

<div
	class="z-50 w-[80%] md:w-1/2 max-w-2xl fixed p-4 bg-white left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 shadow rounded-md dark:bg-darkbackground"
>
	<h1 class="text-2xl mb-4">{$_('Cropping')}</h1>
	<div style="position: relative; width: 100%; height: 300px;">
		{#if image}
			<Cropper
				showGrid={false}
				cropShape={currentlyCroppingProfile ? 'round' : 'rect'}
				{image}
				bind:crop
				bind:zoom
				aspect={currentlyCroppingProfile ? 1 : 5}
				on:cropcomplete={previewCrop}
			/>
		{/if}
	</div>

	<div class="prof-pic-wrapper hidden">
		<!-- <img bind:this={profilePicture} class="prof-pic" src={image} alt="Profile example" {style} /> -->
	</div>
	{#if croppedImage}
		<!-- <h2 class="hidden">{$_('Cropped Output')}</h2>
		<img src={croppedImage} class="hidden" alt="Cropped profile" /><br /> -->
	{/if}
	<div class="mt-6 mb-2">
		<Button buttonStyle="primary" action={handleCrop}>{$_('Confirm')}</Button>
		<Button buttonStyle="secondary" action={cancelAction} Class="bg-gray-500">{$_('Cancel')}</Button
		>
	</div>
</div>

<style>
	.prof-pic-wrapper {
		height: 200px;
		width: 200px;
		position: relative;
		border: solid;
		overflow: hidden;
	}

	.prof-pic {
		position: absolute;
	}
</style>
