<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import CheckboxButtons from '$lib/Generic/CheckboxButtons.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import div from '$lib/Generic/ButtonPrimary.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	export let filter: Filter = { search: '', finished: false, public: false };
	export let handleSearch: () => {};
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;
</script>

<form
	class="bg-white shadow rounded p-6 flex flex gap-4 items-end"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<TextInput
		Class="w-4/5"
		onInput={() => (searched = false)}
		label={$_('Search')}
		bind:value={filter.search}
	/>

	<ButtonPrimary
		Class={`w-8 h-8 !p-1 flex justify-center items-center transition transition-colors ${
			searched ? 'bg-blue-300' : 'bg-blue-600'
		}`}
		type="submit"
	>
		<Fa icon={faMagnifyingGlass} />
	</ButtonPrimary>
	<CheckboxButtons label={''} labels={[{label:'Finished', checked:true}, {label:'Not Finished', checked:true}]} />
	<!--<CheckboxButtons label={''} labels={[{label:'Public', checked:true}, {label:'Private', checked:true}]} /> -->
</form>
