<script>
	import Layout from '$lib/Generic/Layout.svelte';
	import { _ } from 'svelte-i18n';

	import { onMount } from 'svelte';
	import Question from '$lib/Generic/Question.svelte';
	// Or
	// import Swappable from '@shopify/draggable/lib/swappable';
	onMount(() => {
		setUpSwappable();
	});

	const setUpSwappable = async () => {
		const { Swappable, Draggable, Sortable, SortAnimation } = await import('@shopify/draggable');
		const swappable = new Sortable(document.querySelectorAll('ul'), {
			draggable: 'li'
		});
	};
</script>

<Layout centered>
	<Question />

	<div class="bg-white p-6 shadow rounded mt-6">{$_('Under Construction')}</div>

	<ul>
		<li class="cursor-move p-6 bg-white">haii</li>
		<li class="cursor-move p-6 bg-white">haii2</li>
		<li class="cursor-move p-6 bg-white">haii333</li>
		<li class="cursor-move p-6 bg-white">haii4</li>
		<li class="cursor-move p-6 bg-white">hi2</li>

		
	</ul>
</Layout>



<style>
	.thing {
		border:2px gray;
		background: #000;
	}
</style>