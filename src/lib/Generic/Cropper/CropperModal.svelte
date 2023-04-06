<script lang="ts">
	import Cropper from 'svelte-easy-crop';
	import Button from '../Button.svelte';
	import getCroppedImg from './canvasUtils';
	import { _ } from 'svelte-i18n';

	let crop = { x: 0, y: 0 };
	let zoom = 1;
	// let image: any;
	let fileinput, pixelCrop: any;
	export let image: any,
		userEdit: any,
		cancelAction = () => {},
		confirmAction = () => {},
		croppedImage: any;

	function onFileSelected(e: any) {
		let imageFile = e.target.files[0];
		let reader = new FileReader();
		reader.onload = (e) => {
			image = e?.target?.result;
		};
		reader.readAsDataURL(imageFile);
	}

	let profilePicture: any, style: any;

	function previewCrop(e: any) {
		pixelCrop = e.detail.pixels;
		const { x, y, width } = e.detail.pixels;
		const scale = 200 / width;
		profilePicture.style = `margin: ${-y * scale}px 0 0 ${-x * scale}px; width: ${
			profilePicture.naturalWidth * scale
		}px;`;
	}

	async function cropImage() {
		croppedImage = await getCroppedImg(image, pixelCrop);
	}

	function reset() {
		croppedImage = null;
		image = null;
	}
</script>

<div class="z-50 w-[80%] md:w-1/2 max-w-2xl fixed p-4 bg-white left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 shadow rounded-md">
	<h1 class="text-2xl mb-4">{$_("Cropping")}</h1>
	<div style="position: relative; width: 100%; height: 300px;">
		<Cropper
			showGrid={false}
			cropShape="round"
			{image}
			bind:crop
			bind:zoom
			on:cropcomplete={previewCrop}
			aspect={1}
		/>
	</div>
	<!-- <h2>Preview</h2> -->
	<div class="prof-pic-wrapper hidden">
		<img bind:this={profilePicture} class="prof-pic" src={image} alt="Profile example" {style} />
	</div>
	{#if croppedImage}
		<h2 class="hidden">{$_("Cropped Output")}</h2>
		<img src={croppedImage} class="hidden" alt="Cropped profile" /><br />
	{/if}
	<!-- <h2>Preview</h2> -->
	<!-- <div class="prof-pic-wrapper hidden">
		
		<img bind:this={profilePicture} class="prof-pic" src={image} alt="Profile example" {style} />
	</div> -->
	{#if croppedImage}
		<!-- <h2>Cropped Output</h2>
		<img src={croppedImage} alt="Cropped profile" /><br /> -->
	{:else}
	<div class="mt-6 mb-2">
		<Button
			buttonStyle="primary"
			action={async () => {
				croppedImage = await getCroppedImg(image, pixelCrop);
				let blob = new Blob(userEdit.profile_image_file);
				console.log("YOU'RE NOT MY TYPE: ", blob.type)
				
				userEdit.profile_image_file = new File(
					[croppedImage],
					Math.round(Math.random() * 100000000000).toString() + '.jpg',
					{ type: 'image/jpeg' }
				);
				console.log('HIIIII', userEdit.profile_image_file);
				console.log('HIIIII', userEdit.banner_image_file);
				confirmAction();
			}}>{$_("Confirm")}</Button
		>
		<Button buttonStyle="secondary" action={cancelAction} Class="bg-gray-500">{$_("Cancel")}</Button>
	</div>
	{/if}
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
