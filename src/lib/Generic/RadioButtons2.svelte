<script lang="ts" generics="T">
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
		values: T[] = [],
		value: T | null = null,
		Class = '',
		centering = false,
		ClassInner = '',
		icons: null | IconDefinition[] = null,
		radioSide: 'left' | 'right' = 'left',
		horizontal = false;

	export const resetValue = () => {
		var elements = document.getElementsByTagName('input');

		for (var i = 0; i < elements.length; i++) {
			if (
				elements[i].type == 'radio' &&
				labels.find((label) => label === elements[i].id)
			) {
				elements[i].checked = false;
			}
		}
	};

	onMount(() => {
		value = values[0] ?? null;
	});
</script>

<div class={Class}>
	<p class="text-left">{$_(label)}</p>
	<div class={`mt-2 ${centering && 'flex justify-center gap-2'}`}>
		<fieldset
			class:flex={horizontal}
			class="gap-4"
			on:change={(e: any) => {
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
							id={String(values[i])}
							checked={values[i] === value}
						/>{$_(label)}
						{#if icons}
							<Fa icon={icons[i]} />
						{/if}
					{:else}
						{$_(label)}<input
							type="radio"
							{name}
							value={values[i]}
							id={String(values[i])}
							checked={values[i] === value}
						/>
					{/if}
				</label>
			{/each}
		</fieldset>
	</div>
</div>
