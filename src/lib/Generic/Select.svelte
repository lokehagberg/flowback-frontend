<script lang="ts">
	export let onInput: (
			e: Event & {
				currentTarget: EventTarget & HTMLSelectElement;
			}
		) => void = (e) => {},
		label: string = '',
		labels: string[] = [],
		values: any[] = labels,
		value = values[0];
</script>

<select
	name={label}
	on:input={(e) => {
		onInput(e);
		//@ts-ignore
		value = e?.target?.value;
	}}
	class="dark:bg-darkobject"
	{value}
>
	{#each labels as label, i}
		<option value={values[i]} class="dark:bg-darkobject"> {label} </option>
	{/each}
</select>
{#if label}
	<label for={label}>{label}</label> <br />
{/if}
