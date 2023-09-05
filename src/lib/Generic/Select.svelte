<script lang="ts">
	export let onInput: (
			e: Event & {
				currentTarget: EventTarget & HTMLSelectElement;
			}
		) => void = (e) => {},
		label: string = '',
		labels: string[] = [],
		values:any[] = labels;
</script>

<select name={label} on:input={onInput} class="dark:bg-darkobject" >
	{#each labels as label, i}
		<option value={values[i]} class="dark:bg-darkobject"> {label} </option>
	{/each}
</select>
{#if label}
	<label for={label}>{label}</label> <br />
{/if}
