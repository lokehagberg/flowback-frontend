<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let labels: { label: string; checked: boolean; id: number }[] = [
			{ label: 'Yes', checked: false, id: 0 }
		],
		label: string,
		onChange = (id: number) => {},
		Class = ""
</script>

<fieldset>
	<h1 class="text-left text-sm">{$_(label)}</h1>
	<div class={`mt-2 ${Class}`}>
		{#each labels as label}
			<label class="mr-5">
				<input
					type="checkbox"
					name={label.label}
					value={label.checked}
					on:click={() => onChange(label.id)}
					id={`input-${label.id}`}
				/>
				{$_(label.label)}
			</label>
		{/each}
	</div>
</fieldset>
