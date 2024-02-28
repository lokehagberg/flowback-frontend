<script lang="ts">
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import type { proposal } from './interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import SuccessPoppup from '$lib/Generic/SuccessPoppup.svelte';
	import { checkForLinks } from '$lib/Generic/GenericFunctions';

	export let proposal: proposal,
		Class = '',
		onChange = (e:Event) => {};

	export const id: number = 0;

	let isHoveredOver = false,
		show = false;

	onMount(() => {
		checkForLinks(proposal.description, `proposal-${proposal.id}-description`);
	});
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
	class={`select-none dark:bg-darkobject hover:shadow-2xl proposal flex 
	justify-between items-center bg-white gap-8 p-4 border border-gray-200
	 dark:border-gray-500 lg:h-36 xl:h-40 ${Class}`}
	on:dragenter|preventDefault={() => (isHoveredOver = true)}
	on:dragleave|preventDefault={() => (isHoveredOver = false)}
	class:hidden={isHoveredOver}
>
	<div><Fa icon={faBars} /></div>
	<div class="h-full w-2/3">
		<h1 class="text-lg text-left">{proposal.title}</h1>
		<p class="elipsis text-sm mt-2" id={`proposal-${proposal.id}-description`}>
			{proposal.description}
		</p>
	</div>
	<input id="amount" class="dark:bg-darkobject" type="number" on:change={(e) => onChange(e)} min={0} />

	<slot />
</div>

<SuccessPoppup bind:show message="Successfully edited proposal" />

<style>
	.elipsis {
		text-overflow: ellipsis;
		overflow: hidden;
		/* // Addition lines for 2 line or multiline ellipsis */
		display: -webkit-box !important;
		-webkit-line-clamp: 2;
		-webkit-box-orient: vertical;
		white-space: normal;
	}

	.proposal {
		transition: box-shadow 0.15s ease-in;
	}
</style>
