<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	export let filter: Filter = { search: '', finished: false, public: false };
	export let handleSearch: () => {};
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;
</script>

<form
	class="bg-white shadow rounded p-6 flex flex-col gap-4"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<TextInput onInput={() => (searched = false)} label={$_('Search')} bind:value={filter.search} />
	<!-- <CheckboxButtons label={''} labels={[{label:'Finished', checked:true}, {label:'Not Finished', checked:true}]} />
	<CheckboxButtons label={''} labels={[{label:'Public', checked:true}, {label:'Private', checked:true}]} /> -->
	<ButtonPrimary
		Class={`transition transition-colors ${searched && 'bg-blue-300'}`}
		type="submit"
		label="Söka">Search</ButtonPrimary
	>
</form>
