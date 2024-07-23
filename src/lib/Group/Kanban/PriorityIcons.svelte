<script lang="ts">
	import { faChevronUp } from '@fortawesome/free-solid-svg-icons/faChevronUp';
	import { faChevronDown } from '@fortawesome/free-solid-svg-icons/faChevronDown';
	import { faGripLines } from '@fortawesome/free-solid-svg-icons/faGripLines';
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';

	export let priority: number = 3,
	priorityText = [
		'Very low priority',
		'Low priority',
		'Medium priority',
		'High priority',
		'Very high priority',
		],
		Class = '';
</script>

<div class={`${Class} ruby`} title={priorityText[priority - 1]}>
	{#if priority === 1}
		<div class="flex flex-col">
			<Fa icon={faChevronDown} />
			<Fa icon={faChevronDown} class="-mt-2.5" />
		</div>
	{:else if priority === 2}
		<Fa icon={faChevronDown} />
	{:else if priority === 3}
		<Fa icon={faGripLines} />
	{:else if priority === 4}
		<Fa icon={faChevronUp} color="#419EDA" />
	{:else if priority === 5}
		<div class="flex flex-col">
			<Fa icon={faChevronUp} color="#015BC0" />
			<Fa icon={faChevronUp} class="-mt-2.5" color="#015BC0" />
		</div>
	{/if}
</div>

<style>
	.ruby{
		display:ruby
	}
</style>