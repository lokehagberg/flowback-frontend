<script lang="ts">
	export let value = "";
    export let label: string
	export let type = "text"
	export let required = false;
	export let onInput = () => {}
	export let Class = ""
	import { _ } from 'svelte-i18n';

	//Wait what is this?!
	function typeAction(node:{type:string}){
		node.type = type
	}
</script>

<label class={`w-full ${Class}`}
				><p class="text-md mb-1">{$_(label)}</p>
				<input
					required={required}
					use:typeAction
					bind:value
					class={`border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none`}
					on:input={onInput}
				/></label
			>