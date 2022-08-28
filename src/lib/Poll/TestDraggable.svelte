<script lang="ts">
	import { onMount } from 'svelte';

	onMount(async () => {
		const { Sortable } = await import('@shopify/draggable');

		new Sortable(document.querySelectorAll('ul'), {
			draggable: 'li'
		});
	});
</script>

<div class="flex">
<ul class="border border-black w-1/2 select-none">
	<li>1</li>
	<li>2</li>
	<li>3</li>
</ul>

<ul class="border border-black w-1/2 select-none">
    
    <li>4</li>

</ul>
</div>