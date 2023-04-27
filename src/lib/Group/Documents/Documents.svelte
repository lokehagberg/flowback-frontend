<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	// import Button from '$lib/Generic/Button.svelte';
	import Folder from './Folder.svelte';
	import { _ } from 'svelte-i18n';

	let root = [
		{
			name: 'Important work stuff',
			files: [{ name: 'quarterly-results.xlsx' }]
		},
		{
			name: 'Animal GIFs',
			files: [
				{
					name: 'Dogs',
					files: [{ name: 'treadmill.gif' }, { name: 'rope-jumping.gif' }]
				},
				{
					name: 'Goats',
					files: [{ name: 'parkour.gif' }, { name: 'rampage.gif' }]
				},
				{ name: 'cat-roomba.gif' },
				{ name: 'duck-shuffle.gif' },
				{ name: 'monkey-on-a-pig.gif' }
			]
		},
		{ name: 'TODO.md' }
	];

	const groupId = Number($page.params.groupId);
	let folderId: string;

	//TODO: Environment variables probably need to be less cursed
	switch (groupId) {
		case 1:
			folderId = import.meta.env.VITE_DOCUMENT_1;
			break;
		case 2:
			folderId = import.meta.env.VITE_DOCUMENT_2;
			break;
		case 4:
			folderId = import.meta.env.VITE_DOCUMENT_4;
			break;
		case 5:
			folderId = import.meta.env.VITE_DOCUMENT_5;
			break;
		case 9:
			folderId = import.meta.env.VITE_DOCUMENT_9;
			break;
		default:
			folderId = import.meta.env.VITE_DOCUMENT_DEFAULT;
			break;
	}
</script>

<div class="w-full bg-white shadow rounded p-4 pt-6">
	<!-- <a on:click={() => open(`https://drive.google.com/drive/u/0/folders/${folderId}`)} target="_blank" href={`https://drive.google.com/drive/u/0/folders/${folderId}`}
		><Button Class="p-6">{$_("Go to main folder")}</Button></a
	> -->
	<iframe
		title="Documents"
		class="w-full h-[500px] mt-4"
		src={`https://drive.google.com/embeddedfolderview?id=${folderId}#list`}
	/>
</div>

<!-- TODO: Will be implemented later -->

<!-- <div class="w-full bg-white flex items-center flex-col shadow rounded">
	<div class="rounded-full border border-gray-500 p-2 w-1/2 text-center">+ Add Document</div>
	<ul>
		<li>
			<Folder name="Home" files={root} expanded />
		</li>
	</ul>
</div> 

<style>
	ul {
		padding: 0.2em 0 0 0.5em;
		margin: 0 0 0 0.5em;
		list-style: none;
		border-left: 1px solid #eee;
	}

	li {
		padding: 0.2em 0;
	}
</style> -->
