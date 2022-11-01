<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let labels:  {label:string, checked:boolean}[] = [{label:'Yes', checked:false}],
		label: string;
</script>

<fieldset>
	<h1 class="text-left text-sm">{$_(label)}</h1>
	<div class={`mt-2`}>
		{#each labels as label}
			<label class="mr-5">
				<input type="checkbox" name={label.label} value={label.checked} />
				{$_(label.label)}
			</label>
		{/each}
	</div>
</fieldset>
