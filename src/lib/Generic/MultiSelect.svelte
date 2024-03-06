<!-- TODO: Make this component work -->
<script lang="ts">
	import Toggle from './Toggle.svelte';

	let options = [
		{ value: 'option1', label: 'Option 1' },
		{ value: 'option2', label: 'Option 2' },
		{ value: 'option3', label: 'Option 3' },
		{ value: 'option4', label: 'Option 4' }
	];

	let selectedOptions: any = [];

	function toggleOption(event: any) {
        const optionValue = event.target.value;
		console.log(selectedOptions, optionValue);
		if (selectedOptions.includes(optionValue)) {
			selectedOptions = selectedOptions.filter((item: any) => item !== optionValue);
		} else {
			selectedOptions = [...selectedOptions, optionValue];
		}

		console.log(selectedOptions);
	}
</script>

<select multiple on:input={toggleOption} bind:value={selectedOptions}>
	{#each options as option}
		<option value={option.value} >
			{option.label}
		</option>
	{/each}
</select>
