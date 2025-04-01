<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let labels: { label: string; checked: boolean; id: number }[] = [
			{ label: 'Yes', checked: false, id: 0 }
		],
		label: string,
		onChange = (id: number) => {},
		Class = ""
</script>

<fieldset class={Class}>
	{#if label}
		<h1 class="text-left text-sm">{$_(label)}</h1>
	{/if}
	<div class="flex items-center">
		{#each labels as label}
			<label class="mr-5 cursor-pointer flex items-center gap-1" >
				<input
					type="checkbox"
					name={label.label}
					checked={label.checked}
					on:click={() => onChange(label.id)}
					id={`input-${label.id}`}
					class="cursor-pointer"
				/>
				{$_(label.label)}
			</label>
		{/each}
	</div>
</fieldset>
