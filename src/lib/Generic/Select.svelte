<script lang="ts">
	import { _ } from 'svelte-i18n';
	import { elipsis } from './GenericFunctions';
	import { onMount } from 'svelte';

	export let onInput: (
			e: Event & {
				currentTarget: EventTarget & HTMLSelectElement;
			}
		) => void = (e) => {},
		label: string = '',
		labels: string[] = [],
		values: any[] = labels,
		value: any = values[0],
		defaultValue = values[0],
		Class = '',
		classInner = '',
		innerLabel: string | null = 'Select',
		innerLabelOn: boolean = false,
		charlimit = 30;

	onMount(() => {
		value = defaultValue;
	});
</script>

<div class={`${Class} `}>
	{#if label}
		<label for={label}>{label}</label> <br />
	{/if}
	<select
		bind:value
		on:input={(e) => {
			onInput(e);
		}}
		class={`rounded p-1 dark:bg-darkobject ${classInner}`}
		style="width:100%"
		name={label}
	>
		{#if innerLabel}
			<option value="" disabled={!innerLabelOn} selected>{$_(innerLabel)}</option>
		{/if}

		{#if labels}
			{#each labels as label, i}
				<option value={values[i]} class="dark:bg-darkobject"> {elipsis(label)} </option>
			{/each}
		{/if}
	</select>
</div>
