<script lang="ts">
	import Select from '$lib/Generic/Select.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';

	export let sortBy: string | null = null,
		Class = '',
		searchString: string = '';
</script>

<div class={Class}>
	<div class="">
		<TextInput label={''} search={true} max={null} Class="w-[100rem]" inputClass="placeholder-gray-600 pl-6 pr-6 text-gray-500 border-0 bg-gray-100 dark:bg-darkobject" bind:value={searchString} placeholder={$_('Search comments')} />
	</div>

	<div class="w-auto max-w-xs flex flex-row items-center">
		<p class="pr-2">{$_('Sort')}: </p>
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
			Class="border-0 font-semibold"
		/>
	</div>
</div>
