<script lang="ts">
	import Select from '$lib/Generic/Select.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';

	export let sortBy: string | null = null,
		Class = '',
		searchString: string = '';
</script>

<div class={Class}>
	<TextInput label={'Search'} bind:value={searchString} placeholder={$_('Search')} />

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
		labels={[$_('Recent'), $_('Oldest'), $_('Top'), $_('Controversial'), $_('Hot')]}
		{Class}
	/>
</div>
