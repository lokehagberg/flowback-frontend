<script lang="ts">
	export let value = "";
    export let label: string
	export let type = "text"
	export let required = false;

	//Wait what is this?!
	function typeAction(node:{type:string}){
		node.type = type
	}
</script>

<label class="w-full"
				><p class="text-sm mb-1">{label}</p>
				<input
					required={required}
					use:typeAction
					bind:value
					class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
				/></label
			>