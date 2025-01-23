<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let filter: any,
		handleSearch = () => {},
		iterables: any[];
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const handleTags = (e: any) => {
		if (e.target.value === 'null') filter.tag = null;
		else filter.assignee = e.target.value;
		handleSearch();
	};
</script>

<form
	class="bg-white dark:bg-darkobject dark:text-darkmodeText shadow rounded p-6 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
	}}
>
	<div class="w-full flex items-end">
		<select on:input={handleTags} class="dark:bg-darkobject">
			<option value={null}>{$_('All')}</option>
			{#each iterables as iterable}
				<option value={iterable.id}>{iterable.name}</option>
			{/each}
		</select>
	</div>
	<div />
</form>
