<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	export let filter: Filter = {search:"", finished:false, public:false};

	export const filterToURLParameters = () => {
		return '';
	};
</script>

<form class="bg-white shadow rounded p-6 flex flex-col gap-4">
	<TextInput label={$_('Search')} bind:value={filter.search}/>
	<CheckboxButtons label={''} labels={[{label:'Finished', checked:true}, {label:'Not Finished', checked:true}]} />
	<CheckboxButtons label={''} labels={[{label:'Public', checked:true}, {label:'Private', checked:true}]} />
	<ButtonPrimary>Search</ButtonPrimary>
</form>
