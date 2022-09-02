<script lang="ts">
	import Tag from './Tag.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import type { delegate } from './interface';
	import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';
	import TextInput from '$lib/Generic/TextInput.svelte';

	let delegates: delegate[] = [
		{
			id: 1,
			profile_image: null,
			username: 'Loukey',
			tags: ['Math', 'Economics']
		},
		{
			id: 2,
			profile_image: null,
			username: 'Emil',
			tags: ['Gay']
		}
	];

	let tags = ['Economics', 'Math', 'Gay', 'Adventures'];
	
	//Pops up the "Edit tags for delegate" screen for user with the following id, -1 being no delegate
	let selected = -1;

	const changeDelegation = (delegate:delegate, tag: string) => {
		const delegateOld = delegates.find((delegate) => delegate.tags.includes(tag));

		if (delegateOld) delegateOld.tags = delegateOld?.tags.filter((_tag) => _tag !== tag);

		if (delegateOld?.id === delegate.id) {
			delegates = delegates;
			return;
		}

		delegate.tags.push(tag);

		delegates = delegates;
	};
</script>

<div class="flex flex-col items-center gap-2 mb-24 bg-white rounded shadow p-4">
	{#if delegates.length !== 0}
		<ul class="w-full">
			{#each delegates as delegate}
				<li class="flex justify-between bg-white p-2 w-full">
					<div class="flex">
						<div class="bg-red-500 w-10 h-10" />
						<div class="w-64 ml-10">{delegate.username}</div>
					</div>
					<div class="flex gap-2 items-center">
						{#each delegate.tags as tag}
							<Tag {tag} />
						{/each}
						<div class="relative">
							<div
								class="cursor-pointer"
								on:click={() =>
									selected === delegate.id ? (selected = -1) : (selected = delegate.id)}
							>
								<div class="faPlus" class:selected={selected === delegate.id}>
									<Fa icon={faPlus} size="2x" />
								</div>
							</div>
							<div
								class="absolute bg-white p-6 w-64 shadow rounded border border-gray-200 z-50 right-5"
								class:invisible={selected !== delegate.id}
							>
								<h1 class="text-xl">Edit tags for {delegate.username}</h1>
								<TextInput label="Search" />
								<ul class="mt-6 flex flex-col gap-6 items-center">
									{#each tags as tag}
										<li class="w-full" on:click={() => changeDelegation(delegate, tag)}>
											<Tag
												{tag}
												className={delegate.tags.includes(tag) ? 'bg-blue-300' : 'bg-blue-600'}
											/>
										</li>
									{/each}
								</ul>
							</div>
						</div>
					</div>
				</li>
			{/each}
		</ul>
	{/if}
</div>

<style>
	.faPlus {
		transition: transform 400ms cubic-bezier(0.075, 0.82, 0.165, 1);
	}

	.selected {
		transform: rotate(45deg);
	}
</style>
