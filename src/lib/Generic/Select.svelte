<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { elipsis } from './GenericFunctions';

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
		innerLabel = 'Select',
		charlimit = 30;
</script>

<div class={`${Class}`}>
	{#if label}
		<label for={label}>{label}</label> <br />
	{/if}
	<select
		bind:value
		on:input={(e) => {
			onInput(e);
			//@ts-ignore
			// if (e?.target?.value)
			// 	//@ts-ignore
			// 	value = e?.target?.value;
		}}
		class={`rounded p-1 dark:bg-darkobject ${classInner}`}
		style="width:100%"
		name={label}
	>
		<option value="" selected>{$_(innerLabel)}</option>
		{#each labels as label, i}
			<option value={values[i]} class="dark:bg-darkobject"> {elipsis(label)} </option>
		{/each}
	</select>
</div>
