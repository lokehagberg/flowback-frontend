<script lang="ts">
	export let onInput: (
			e: Event & {
				currentTarget: EventTarget & HTMLSelectElement;
			}
		) => void,
		label: string,
		options: string[];
</script>

<select name={label} on:input={onInput} class="dark:bg-darkobject">
	{#each options as option}
		<option value={option} class="dark:bg-darkobject"> {option} </option>
	{/each}
</select>
<label for={label}>{label}</label> <br />
