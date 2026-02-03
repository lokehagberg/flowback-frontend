<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let value: string | null = '',
		label: string,
		required = false,
		Class = '',
		areaClass = '',
		onBlur = () => {},
		autofocus = false,
		max = 5000,
		displayMax = true,
		onKeyPress = (e: any) => {},
		inputClass = '',
		rows = 2,
		recentlyTappedButton = '',
		placeholder: string = '',
		id = `textarea`;

	const onKeyDown = (e: any) => {
		recentlyTappedButton = e.target.value[e.target.value.length - 1];
	};

	const expandableTextArea = () => {
		const textarea = document.getElementById(`textarea`);

		if (!textarea) return;

		textarea.oninput = function () {
			if (textarea.scrollHeight < 500) {
				textarea.style.height = ''; /* Reset the height*/
				textarea.style.height = textarea.scrollHeight + 'px';
			}
		};
	};

	const focus = () => {
		const textarea = document.getElementById(`textarea-${id}`);
		if (!textarea) return;

		textarea.focus();
	};

	onMount(() => {
		expandableTextArea();
		if (autofocus) focus();
	});
</script>

<label class={`${Class}`}>
	<div class="flex justify-between w-full items-center">
		<div>
			<p class="text-md mb-1 inline">{$_(label)}</p>
			{#if required}
				<p class="inline text-red-600">*</p>
			{/if}
		</div>

		{#if max && displayMax}
			<p
				class="inline text-right dark:brightness-50 dark:text-darkmodeText text-gray-400 dark:text-gray-700 text-xs"
			>
				{value?.length || 0}/{max}
			</p>
		{/if}
	</div>
	<textarea
		class={`${areaClass} dark:text-darkmodeText dark:bg-darkbackground border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none ${inputClass}`}
		{id}
		{required}
		{rows}
		maxlength={max}
		bind:value
		on:blur={onBlur}
		on:keypress={onKeyPress}
		on:input={onKeyDown}
		autocomplete="off"
		{placeholder}
	/>
</label>
