<script lang="ts">
	import { faTimes, faPaperclip } from '@fortawesome/free-solid-svg-icons';
	import FileUpload from './FileUpload.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';

	export let files: File[] = [],
		minimalist = false,
		Class = '',
		disableCropping = false;

	let file: File | null = null;

	const removeFile = (index: number) => {
		files.splice(index, 1);
		files = files;
	};
</script>

{#if files.length > 0}
	<div>
		{#each files as file, i}
			<div
				class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300"
			>
				{file.name}
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
		? `${Class} inline m-auto`
		: `${Class} rounded flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300`}
>
	{#if !minimalist}{$_('Add files')}{/if}
	<FileUpload
		icon={faPaperclip}
		bind:croppedImage={file}
		minimalist
		Class="dark:text-white"
		label=""
		iconSize="1.2x"
		disableImagePreview
		onCrop={() => {
			if (file) {
				files.push(file);
				files = files;
			}
		}}
		{disableCropping}
	/>
</div>
