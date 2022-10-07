<script lang="ts">
	export let value = '';
	export let label: string;
	export let required = false;
	export let Class = '';

	const expandTextArea = (e: any) => {
		value = e.target.value;
	};
</script>

<label class={`${Class}`}
	><p class="text-sm mb-1">{label}</p>
	<textarea
		{required}
		on:input={expandTextArea}
		bind:value
		class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
	/>
</label>
