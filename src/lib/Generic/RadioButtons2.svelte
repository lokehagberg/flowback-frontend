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
		centering = false,
		ClassInput = '';
</script>

<div class={Class}>
	<h1 class="text-left text-sm">{$_(label)}</h1>
	<div class={`mt-2 ${centering && 'flex justify-center gap-2'}`}>
		<fieldset
			on:change={(e) => {
				//@ts-ignore
				value = e?.target?.value;
			}}
		>
			{#each labels as label}
				<div class={ClassInput}>
					<label> <input type="radio" name={'radio'} value={label} id={label} />{label}</label>
				</div>
			{/each}
		</fieldset>
	</div>
</div>
