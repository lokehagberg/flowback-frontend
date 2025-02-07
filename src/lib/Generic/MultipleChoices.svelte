<script lang="ts">
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { _ } from 'svelte-i18n';
	import SuccessPoppup from './SuccessPoppup.svelte';
	import { faEllipsis } from '@fortawesome/free-solid-svg-icons';

	export let choicesOpen = false,
		labels: string[],
		Class = '',
		functions: any[] = [];

	let popupMessage: string = '',
		show = false;

	const closeWindowWhenClickingOutside = () => {
		window.addEventListener('click', function (e) {
			if (
				choicesOpen &&
				//@ts-ignore
				![...document.getElementsByClassName(`notifications-clickable-region`)]?.find((element) =>
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

<div class={`${Class} notifications-clickable-region`}>
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
		<div class="z-50 absolute mt-2 bg-white dark:bg-darkobject shadow-xl text-sm right-0">
			<div class="text-xs p-2">{$_('Actions')}</div>
			{#each labels as label, i}
				<button
					on:click={() => functions[i]()}
					class=" bg-white w-full hover:bg-gray-300 active:bg-gray-400 dark:bg-slate-700 dark:hover:bg-slate-800 dark:active:bg-slate-900 p-2 px-5 flex justify-between items-center hover:cursor-pointer transition-all"
					>{label}</button
				>
			{/each}
		</div>
	{/if}
</div>
<SuccessPoppup bind:show bind:message={popupMessage} />
