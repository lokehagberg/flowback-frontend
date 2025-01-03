<script lang="ts">
	import Select from '$lib/Generic/Select.svelte';
	import { _ } from 'svelte-i18n';

	export let sortBy: string | null = null, Class = ""
</script>

<div class={Class}>
	<Select
		innerLabel={$_('Select Sorting')}
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
			$_('Recent'),
			$_('Oldest'),
			$_('Top'),
			$_('Controversial'),
			$_('Hot')
		]}
		{Class}
	/>
</div>
