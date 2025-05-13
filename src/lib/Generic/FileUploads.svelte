<script lang="ts">
	import { faUpload, faTimes, faPlus, faPaperclip, faImage, faFile } from '@fortawesome/free-solid-svg-icons';
	import FileUpload from './FileUpload.svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';

	export let files: (File | string | { file: string })[] = [],
		minimalist = false,
		Class = '',
		disableCropping = false,
		editMode = false;

	let file: File | null = null;

	const removeFile = (index: number) => {
		files.splice(index, 1);
		files = files;
	};

	const getFileName = (file: File | string | { file: string }): string => {
		if (typeof file === 'string') {
			const urlParts = file.split('/');
			return urlParts[urlParts.length - 1];
		} else if (file instanceof File) {
			return file.name;
		} else if (file && typeof file === 'object' && 'file' in file) {
			const urlParts = file.file.split('/');
			return urlParts[urlParts.length - 1];
		}
		return 'Unknown file';
	};

	const isImage = (file: File | string | { file: string }): boolean => {
		let fileName: string;
		
		if (typeof file === 'string') {
			fileName = file;
		} else if (file instanceof File) {
			fileName = file.name;
		} else if (file && typeof file === 'object' && 'file' in file) {
			fileName = file.file;
		} else {
			return false;
		}
		
		const ext = fileName.split('.').pop()?.toLowerCase();
		return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext || '');
	};
</script>

{#if files.length > 0}
	<div>
		{#each files as file, i}
			<div
				class="flex justify-between items-center p-2 border dark:border-gray-500 border-gray-300 mb-1"
			>
				<div class="flex items-center">
					{#if isImage(file)}
						<span class="text-blue-500 mr-2">
							<Fa icon={faImage} />
						</span>
					{:else}
						<span class="text-red-500 mr-2">
							<Fa icon={faFile} />
						</span>
					{/if}
					<span class="truncate max-w-[200px]">{getFileName(file)}</span>
				</div>
				<button
					class="ml-2 text-red-500 hover:text-red-700"
					on:click={() => removeFile(i)}
					type="button"
					aria-label="Remove file"
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
		Class=""
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
