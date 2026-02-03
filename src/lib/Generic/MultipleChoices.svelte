<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import { faEllipsis } from '@fortawesome/free-solid-svg-icons';

	export let choicesOpen = false,
		labels: string[],
		Class = '',
		ClassInner = '',
		functions: any[] = [],
		id = 'multiple-choices';

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				choicesOpen &&
				//@ts-ignore
				![
					...document.getElementsByClassName(`notifications-clickable-region`)
				]?.find((element) =>
					//@ts-ignore
					element.contains(e.target)
				)
			) {
				choicesOpen = false;
			}
		});
	};

	onMount(() => {
		closeWindowWhenClickingOutside();
	});
</script>

<div class={`${Class} notifications-clickable-region relative`} {id}>
	<button
		class={``}
		on:click={() => {
			choicesOpen = !choicesOpen;
		}}
		on:keydown
	>
		<Fa
			class="hover:cursor-pointer hover:text-primary dark:text-secondary"
			icon={faEllipsis}
			rotate="90"
			size={'1.2x'}
		/>
	</button>

	{#if choicesOpen}
		<div
			class={`${ClassInner} z-50 absolute bg-white dark:bg-darkobject dark:text-darkmodeText shadow-xl text-sm`}
		>
			<div class="text-xs p-2">{$_('Actions')}</div>
			{#each labels as label, i}
				<button
					on:click={() => functions[i]()}
					class="bg-white w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 py-2 px-4 hover:cursor-pointer transition-all whitespace-nowrap"
					>{$_(label)}</button
				>
			{/each}
		</div>
	{/if}
</div>
