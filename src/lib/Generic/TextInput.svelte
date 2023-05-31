<script lang="ts">
	import { onMount } from 'svelte';

	export let value = '',
		autofocus = false,
		label: string,
		type = 'text',
		required = false,
		onInput = () => {},
		Class = '',
		onBlur = () => {},
		inputClass = '';

	import { _ } from 'svelte-i18n';

	//Wait what is this?!
	function typeAction(node: { type: string }) {
		node.type = type;
	}

	onMount(() => {
		const input = document.getElementById(`textinput-${label}`);
		if (autofocus) input?.focus();
	});
</script>

<label class={`w-full ${Class}`}
	><p class="text-md mb-1 dark:text-darkmodeText">{$_(label)}</p>
	<input
		{required}
		on:blur={onBlur}
		use:typeAction
		bind:value
		class={`dark:text-darkmodeText dark:bg-slate-500 border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
		id={`textinput-${label}`}
		on:input={onInput}
		max="100"
	/></label
>
