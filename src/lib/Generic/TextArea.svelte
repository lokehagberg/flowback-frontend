<script lang="ts">
	import { onMount } from 'svelte';
	import { _ } from 'svelte-i18n';

	export let value = '';
	export let label: string;
	export let required = false;
	export let Class = '';

	const expandTextArea = (e: any) => {
		value = e.target.value;
	};

	const expandableTextArea = () => {
		const textarea = document.getElementById('textarea');
		if (!textarea) return;

		textarea.oninput = function () {
			if (textarea.scrollHeight < 500){
				textarea.style.height = ''; /* Reset the height*/
				textarea.style.height = textarea.scrollHeight + 'px';
			}
		};
	};

	onMount(() => {
		expandableTextArea();
	});
</script>

<label class={`${Class}`}
	><p class="text-sm mb-1">{$_(label)}</p>
	<textarea
		id="textarea"
		{required}
		on:input={expandTextArea}
		bind:value
		class="border border-gray-300 border-solid rounded focus:bg-gray-100 p-0.5 w-full outline-none"
	/>
</label>
