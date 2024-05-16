<script lang="ts">
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { _ } from 'svelte-i18n';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faMagnifyingGlass } from '@fortawesome/free-solid-svg-icons/faMagnifyingGlass';
	import Button from '$lib/Generic/Button.svelte';

	export let filter:any = {},
        getGroups: () => void;
	//Aesthethics only, changes the UI when searching would lead to different results.
	let searched = true;

	const handleChangeMember = (e: any) => {
		filter.joined = e.target.value;
		getGroups()
	};
    
	const handleSearch = (e: any) => {
        // console.log(filter)
        // filter.search = e.target.value;
        getGroups();
    };
</script>

<form
	class="bg-white dark:bg-darkobject shadow rounded p-6 flex flex-col md:w-[40%] w-[90%] gap-4"
	on:submit|preventDefault={handleSearch}
>
	<div class="w-full flex items-end">
		<TextInput
			Class="w-4/5"
			onInput={() => (searched = false)}
			label={$_('Search')}
			bind:value={filter.search}
		/>

		<Button
			Class={`w-8 h-8 ml-4 !p-1 flex justify-center items-center ${
				searched ? 'bg-blue-300' : 'bg-blue-600'
			}`}
			type="submit"
		>
			<Fa icon={faMagnifyingGlass} />
		</Button>
	</div>
	<div>
		<select on:input={handleChangeMember} class="dark:bg-darkobject text-gray-300">
			<option value="all">{$_('All')}</option>
			<option value="member">{$_('Member')}</option>
			<option value="not-member">{$_('Not member')}</option>
		</select>
	</div>
</form>
