<script lang="ts">
	export let Yes: boolean = true, label:string;
</script>

<fieldset>
	<h1 class="text-left text-sm">{label}?</h1>
	<div class="mt-2">
        <label class="ml-4">
            Yes
            <input type="radio" name={label} checked={Yes} on:change={() => (Yes = true)} />
        </label>
		<label>
			No
			<input type="radio" name={label} checked={!Yes} on:change={() => (Yes = false)} />
		</label>
	</div>
</fieldset>
