<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let value = '',
		autofocus = false,
		label: string,
		required = false,
		onInput = () => {},
		Class = '',
		onBlur = () => {},
		inputClass = '',
		placeholder = '',
		max: number | null = 100,
		type: 'text' | 'password' = 'text',
		name: string = '';

	onMount(() => {
		const input = document.getElementById(`textinput-${label}`);
		if (autofocus) input?.focus();
	});
</script>

<label class={`w-full ${Class}`}>
	<div class="flex justify-between w-full items-center">
		<div>
			{#if label}
				<p class="text-md mb-1 dark:text-darkmodeText inline">{$_(label)}</p>
			{/if}
			{#if required}
				<p class="inline text-red-600">*</p>
			{/if}
		</div>

		{#if max}
			<p class="dark:brightness-50 dark:text-darkmodeText text-gray-400 text-xs">
				{value.length}/{max}
			</p>{/if}
	</div>
	{#if type === 'text'}
		<input
			bind:value
			id={`textinput-${label}`}
			class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
			{required}
			maxlength={max}
			placeholder={$_(placeholder)}
			on:blur={onBlur}
			on:input={onInput}
			{name}
		/>
	{:else if type === 'password'}
		<input
			id={`textinput-${label}`}
			class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
			{required}
			maxlength={max}
			placeholder={$_(placeholder)}
			bind:value
			on:blur={onBlur}
			on:input={onInput}
			type="password"
			{name}
		/>
	{/if}
</label>
