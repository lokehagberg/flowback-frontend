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
		inputClass = '',
		placeholder = '',
		max = 100;

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
	><p class="text-md mb-1 dark:text-darkmodeText inline">{$_(label)}</p>
	{#if required}
		<p class="inline text-red-600">*</p>
	{/if}

	{#if max}
		<p class="inline text-right dark:brightness-50 dark:text-darkmodeText text-gray-400">
			{value.length}/{max}
		</p>{/if}

	<input
		id={`textinput-${label}`}
		class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
		{required}
		maxlength={max}
		{placeholder}
		bind:value
		on:blur={onBlur}
		on:input={onInput}
		use:typeAction
	/></label
>
