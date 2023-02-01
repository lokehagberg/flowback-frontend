<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let value = '',
		label: string,
		required = false,
		Class = '',
		onBlur = () => {},
		autofocus = false,
		max = 2000,
		onKeyPress = (e:any) => {};

	const expandTextArea = (e: any) => {
		value = e.target.value;
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
	}

	onMount(() => {
		expandableTextArea();
		if (autofocus) focus();
	});
</script>

<label class={`${Class}`}
	><p class="text-sm mb-1">{$_(label)}</p>
	<textarea
		on:blur={onBlur}
		id="textarea"
		{required}
		on:input={expandTextArea}
		on:keypress={onKeyPress}
		bind:value
		class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
		maxlength={max}
	/>
</label>
