<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let onInput: (
			e: Event & {
				currentTarget: EventTarget & HTMLSelectElement;
			}
		) => void = (e) => {},
		label: string = '',
		labels: string[] = [],
		values: any[] = labels,
		value = values[0],
		Class = '',
		classInner = '',
		innerLabel = 'Select';
</script>

<div class={`${Class}`}>
	{#if label}
		<label for={label}>{label}</label> <br />
	{/if}
	<select
		name={label}
		on:input={(e) => {
			onInput(e);
			//@ts-ignore
			value = e?.target?.value;
		}}
		class={`dark:bg-darkobject ${classInner}`}
		bind:value
	>
		<option value="" disabled selected>{innerLabel}</option>
		{#each labels as label, i}
			<option value={values[i]} class="dark:bg-darkobject"> {$_(label)} </option>
		{/each}
	</select>
</div>
