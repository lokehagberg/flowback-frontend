<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let Yes: boolean = true, label:string;
</script>

<fieldset>
	<h1 class="text-left text-sm">{$_(label)}?</h1>
	<div class="mt-2">
        <label class="ml-4">
            {$_("Yes")}
            <input type="radio" name={label} checked={Yes} on:change={() => (Yes = true)} />
        </label>
		<label>
			{$_("No")}
			<input type="radio" name={label} checked={!Yes} on:change={() => (Yes = false)} />
		</label>
	</div>
</fieldset>
