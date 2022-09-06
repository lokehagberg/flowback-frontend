<script lang="ts">
	export let value = '';
	export let label: string;

	const f = (e:any) => {
		console.log(e.dataset)
		e.parentNode.dataset.replicatedValue = e.value
	}
</script>

<label class=""
	><p class="text-sm mb-1">{label}</p>
	<textarea
		on:input={f}
		bind:value
		class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
	/>
</label>
