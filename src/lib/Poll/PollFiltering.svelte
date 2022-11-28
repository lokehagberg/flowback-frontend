<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import type { Filter } from './interface';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';

	export let filter: Filter = { search: '', finishedSelection:"all", public: false };
	export let handleSearch: () => {};
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const handleFinishedSelection = (e:any) => {
		filter.finishedSelection = e.target.value
		handleSearch();
	}
</script>

<form
	class="bg-white shadow rounded p-6 flex flex-col w-full gap-4"
	on:submit|preventDefault={() => {
		searched = true;
		handleSearch();
	}}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			onInput={() => (searched = false)}
			label={$_('Search')}
			bind:value={filter.search}
		/>

		<ButtonPrimary
			Class={`w-8 h-8 ml-4 !p-1 flex justify-center items-center transition transition-colors ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</ButtonPrimary>
	</div>
	<div>
		<select on:input={handleFinishedSelection}>
			<option value="all">Alla</option>
			<option value="unfinished">Igång</option>
			<option value="finished">Färdiga</option>
		</select>
		<!-- <CheckboxButtons
			label={''}
			labels={[
				{ label: 'Finished', checked: false },
				{ label: 'Not Finished', checked: false }
			]}
		/>
	</div> -->
	<!--<CheckboxButtons label={''} labels={[{label:'Public', checked:true}, {label:'Private', checked:true}]} /> -->
</form>
