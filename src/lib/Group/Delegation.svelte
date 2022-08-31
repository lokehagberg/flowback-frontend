<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { User } from './interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	let users: User[] = [
		{
			id: 1,
			profile_image: null,
			username: 'Loukey'
		},
		{
			id: 2,
			profile_image: null,
			username: 'Emil'
		}
	];

	let tags = ['Economics', 'Math'];
	let selected = 1;
</script>

<div class="flex flex-col items-center gap-2 mb-24 bg-white">
	{#if users.length !== 0}
		<ul class="w-full">
			{#each users as user}
				<li class="flex justify-between bg-white p-2 w-full">
					<div class="flex">
						<div class="bg-red-500 w-10 h-10" />
						<div class="w-64 ml-10">{user.username}</div>
					</div>
					<div class="flex">
						{#each tags as tag}
							<div class="bg-blue-500 p-2 ml-2 cursor-pointer">{tag}</div>
						{/each}
						<div class="relative">
							<div on:click={() => (selected = user.id)}>
								<Fa icon={faPlus} />
							</div>
							<div class="absolute bg-white" class:invisible={selected !== user.id}>
								Search for tags
							</div>
						</div>
					</div>
				</li>
			{/each}
		</ul>
	{/if}
</div>
