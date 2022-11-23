<script lang="ts">
	import { page } from '$app/stores';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
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

	switch (groupId) {
		case 1:
			folderId = '1RPO5L-jboVB_AfReTu-kV2Vy6gTfhr2P';
			break;
		case 2:
			folderId = '1aAVp1GjYDTfx_w3FHmp3o1dHYA6AJniY';
			break;
		case 4:
			folderId = '1nXWjUfbn7qvLUIwiNmPETIHuYISy8L3P';
			break;
		case 5:
			folderId = '1FM_pMKZKRUbpL48szxmp2dGD-8xaTmVB';
			break;
		default:
			break;
	}
</script>

<div class="w-full bg-white shadow rounded p-4 pt-6">
	<a on:click={() => open(`https://drive.google.com/drive/u/0/folders/${folderId}`)} target="_blank" href={`https://drive.google.com/drive/u/0/folders/${folderId}`}
		><ButtonPrimary Class="p-6">{$_("Go to main folder")}</ButtonPrimary></a
	>
	<iframe
		title="Documents"
		class="w-full h-[500px] mt-4"
		src={`https://drive.google.com/embeddedfolderview?id=${folderId}#list`}
	/>
</div>

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
