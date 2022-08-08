<script lang="ts">
	import './index.css';

	export let value: String;
    export let label: String

</script>

<label class="mt-5 w-2/3"
				><p class="text-sm mb-1">{label}</p>
				<input
					type="text"
					bind:value={value}
					class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
				/></label
			>

