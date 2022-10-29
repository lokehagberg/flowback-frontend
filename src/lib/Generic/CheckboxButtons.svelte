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
				{$_(label.label)}
				<input type="checkbox" name={label.label} value={label.checked} />
			</label>
		{/each}
	</div>
</fieldset>
