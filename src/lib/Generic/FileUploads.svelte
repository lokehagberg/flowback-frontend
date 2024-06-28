<script lang="ts">
	import { faUpload, faUser } from '@fortawesome/free-solid-svg-icons';
	import ImageUpload from './ImageUpload.svelte';

	export let image: File | null = null;

	let images: File[] | null = null;
</script>

<div class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300">
    Add media
	<ImageUpload
		icon={faUpload}
		bind:croppedImage={image}
		minimalist
		label=""
		iconSize="1.5x"
	/>
</div>
