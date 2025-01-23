<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let Yes: boolean = true, label:string, centering = false, Class=""
</script>

<fieldset class={Class}>
	<h1 class="text-left text-sm">{$_(label)}</h1>
	<div class={`${centering && "flex justify-center gap-2"}`}>
        <label>
            {$_("Yes")}
            <input type="radio" name={label} checked={Yes} on:change={() => (Yes = true)} />
        </label>
		<label>
			{$_("No")}
			<input type="radio" name={label} checked={!Yes} on:change={() => (Yes = false)} />
		</label>
	</div>
</fieldset>
