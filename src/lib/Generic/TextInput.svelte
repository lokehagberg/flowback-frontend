<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';
	import Fa from 'svelte-fa';
	import { faSearch, faTimes } from '@fortawesome/free-solid-svg-icons';

	export let value: string = '',
		autofocus = false,
		label: string,
		required = false,
		onInput = () => {},
		Class = '',
		onBlur = () => {},
		inputClass = '',
		placeholder = '',
		max: number | null = 100,
		type: 'text' | 'password' | 'email' = 'text',
		search = false,
		name: string = '';

	function clearInput() {
		value = '';
	}

	onMount(() => {
		const input = document.getElementById(`textinput-${label}`);
		if (autofocus) input?.focus();
	});

	$: value === null && (value = '');
</script>

<!-- TODO: Fix this file -->
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
		<div class="relative w-full">
			{#if search}
				<Fa
					icon={faSearch}
					class="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-500"
				/>
			{/if}
			<input
				bind:value
				class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass} ${
					search ? ' pl-10 ' : ''
				}`}
				id={`textinput-${label}`}
				placeholder={$_(placeholder)}
				maxlength={max}
				on:blur={onBlur}
				on:input={onInput}
				autocomplete="off"
				{required}
				{name}
			/>
			{#if value && search}
				<button
					class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 focus:outline-none"
					type="button"
					on:click={clearInput}
				>
					<Fa icon={faTimes} />
				</button>
			{/if}
		</div>
	{:else if type === 'password'}
		<input
			class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
			placeholder={$_(placeholder)}
			id={`textinput-${label}`}
			maxlength={max}
			type="password"
			bind:value
			on:blur={onBlur}
			on:input={onInput}
			autocomplete="off"
			{required}
			{name}
		/>
	{:else if type === 'email'}
		<input
			class={`dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
			placeholder={$_(placeholder)}
			id={`textinput-${label}`}
			maxlength={max}
			type="email"
			bind:value
			on:blur={onBlur}
			on:input={onInput}
			autocomplete="off"
			{required}
			{name}
		/>
	{/if}
</label>
