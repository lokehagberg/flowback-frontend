<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let value = '',
		label: string,
		required = false,
		Class = '',
		onBlur = () => {},
		autofocus = false,
		max = 5000,
		onKeyPress = (e: any) => {},
		inputClass = '',
		rows = 2,
		recentlyTappedButton = '',
		id = '';

	const onKeyDown = (e: any) => {
		recentlyTappedButton = e.target.value[e.target.value.length - 1];
	};

	const expandableTextArea = () => {
		const textarea = document.getElementById('textarea');
		if (!textarea) return;

		textarea.oninput = function () {
			if (textarea.scrollHeight < 500) {
				textarea.style.height = ''; /* Reset the height*/
				textarea.style.height = textarea.scrollHeight + 'px';
			}
		};
	};

	const focus = () => {
		const textarea = document.getElementById('textarea');
		if (!textarea) return;

		textarea.focus();
	};

	onMount(() => {
		expandableTextArea();
		if (autofocus) focus();
	});
</script>

<label class={`${Class}`} {id}
	><p class="text-sm mb-1 inline">{$_(label)}</p>
	{#if required}
		<p class="inline text-red-600">*</p>
	{/if}

	{#if max}
		<p class="inline text-right dark:brightness-50 dark:text-darkmodeText text-gray-400">
			{value.length}/{max}
		</p>
	{/if}

	<textarea
		class={`dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
		id="textarea"
		{required}
		{rows}
		maxlength={max}
		bind:value
		on:blur={onBlur}
		on:keypress={onKeyPress}
		on:input={onKeyDown}
	/>
</label>
