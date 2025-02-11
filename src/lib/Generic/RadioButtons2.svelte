<script lang="ts">
	import type { IconDefinition } from '@fortawesome/free-solid-svg-icons';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	// Name is mandatory so as to collect the different radtio button elements into one group,
	// and distinguish them from other groups.
	export let name: string,
		onChange = (e: any) => {},
		label: string = '',
		labels: string[] = [],
		values: any[] = labels,
		value: any | null = values[0],
		Class = '',
		centering = false,
		ClassInner = '',
		icons: null | IconDefinition[] = null,
		radioSide: 'left' | 'right' = 'left',
		horizontal = false;

	export const resetValue = () => {
		var elements = document.getElementsByTagName('input');

		for (var i = 0; i < elements.length; i++) {
			if (elements[i].type == 'radio' && labels.find((label) => label === elements[i].id)) {
				elements[i].checked = false;
			}
		}
	};

	onMount(() => {
		value = values[0];
	});
</script>

<div class={Class}>
	<h1 class="text-left text-sm">{$_(label)}</h1>
	<div class={`mt-2 ${centering && 'flex justify-center gap-2'}`}>
		<fieldset
			class:flex={horizontal}
			class="gap-4"
			on:change={(e) => {
				//@ts-ignore
				value = e?.target?.value;
				onChange(value);
			}}
		>
			{#each labels as label, i}
				<label class={ClassInner}>
					{#if radioSide === 'left'}
						<input
							type="radio"
							{name}
							value={values[i]}
							id={values[i]}
							checked={values[i] === value}
						/>{$_(label)}
						{#if icons} <Fa icon={icons[i]} /> {/if}
					{:else}
						{$_(label)}<input
							type="radio"
							{name}
							value={values[i]}
							id={values[i]}
							checked={values[i] === value}
						/>
					{/if}
				</label>
			{/each}
		</fieldset>
	</div>
</div>
