<script lang="ts">
	import { onMount } from 'svelte';

	export let value = '',
		autofocus = false,
		label: string,
		type = 'text',
		required = false,
		onInput = () => {},
		Class = '',
		onBlur = () => {};
		
	import { _ } from 'svelte-i18n';

	//Wait what is this?!
	function typeAction(node: { type: string }) {
		node.type = type;
	}

	onMount(() => {
		const input = document.getElementById(`textinput-${label}`);
		if (autofocus) input?.focus();
	})
</script>

<label class={`w-full ${Class}`}
	><p class="text-md mb-1">{$_(label)}</p>
	<input
		{required}
		on:blur={onBlur}
		use:typeAction
		bind:value
		class={`border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none`}
		id = {`textinput-${label}`}
		on:input={onInput}
	/></label
>
