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
		value: any = '',
		Class = '',
		classInner = '',
		innerLabel: string | null = 'Select',
		innerLabelOn: boolean = false,
		charlimit = 30,
		disableFirstChoice = false,
		id: string = '',
		disabled = false,
		innerLabelValue: any = '';

	// onMount(() => {
	// 	value = defaultValue;
	// });
</script>

<div class={`${Class} `}>
	{#if label}
		<label for={label}>{$_(label)}</label> <br />
	{/if}
	<select
		bind:value
		{disabled}
		class:dark:text-gray-500={disabled}
		class:text-gray-400={disabled}
		on:input={(e) => {
			onInput(e);
		}}
		class={`rounded p-1 dark:bg-darkobject ${classInner}`}
		style="width:100%"
		name={label}
		{id}
	>
		{#if innerLabel}
			<option value={innerLabelValue} disabled={disableFirstChoice} selected
				>{$_(innerLabel)}</option
			>
		{/if}

		{#if labels}
			{#each labels as label, i}
				<option value={values[i]} class="dark:bg-darkobject">
					{elipsis($_(label))}
				</option>
			{/each}
		{/if}
	</select>
</div>
