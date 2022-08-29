<script lang="ts">
	import type { User } from './interface';
	let users: User[] = [
		{
			id: 1,
			profile_image: null,
			username: 'hi'
		}
	];

	let tags = ['Economics', 'Math'];
</script>

<div class="flex flex-col items-center gap-2 mb-24">
	{#if users.length !== 0}
		<ul>
			{#each users as user}
				<li class="flex bg-white p-2 w-full">
					<div class="bg-red-500 w-10 h-10" />
					<div class="w-64 ml-10">{user.username}</div>
					{#each tags as tag}
						<div class="bg-blue-500 p-2 ml-2 cursor-pointer">{tag}</div>
					{/each}
				</li>
			{/each}
		</ul>
	{/if}
</div>
