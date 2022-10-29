<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
import Folder from './Folder.svelte';

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
</script>

<div class="w-full bg-white shadow rounded p-4 pt-6">
	<ButtonPrimary Class="p-6" action={() => open("https://drive.google.com/drive/u/0/folders/1tNZW9-xdClz4KHLU7zWqHB7Rfi8YyUz-")}>Gå till huvudmappen</ButtonPrimary>
	<iframe title="Documents" class="w-full h-[500px] mt-4" src="https://drive.google.com/embeddedfolderview?id=1tNZW9-xdClz4KHLU7zWqHB7Rfi8YyUz-#list"></iframe>
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
