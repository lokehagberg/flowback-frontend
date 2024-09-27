<script lang="ts">
	import Select from '$lib/Generic/Select.svelte';

	export let sortBy: string | null = null;
</script>

<div>
	Sort by: <Select
		innerLabel="Select Sorting"
		values={[
			'created_at_asc',
			'created_at_desc',
			// 'total_replies_asc',
			// 'total_replies_desc',
			'score_asc',
			'score_desc',
			null
		]}
		bind:value={sortBy}
		labels={[
			'Recent',
			'Oldest',
			'Top',
			'Controversial',
			'Hot'
		]}
	/>
	filter Sorting
</div>
