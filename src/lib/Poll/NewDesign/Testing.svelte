<script>
	import Fillibuster from './Fillibuster.svelte';
</script>

<Fillibuster>
	<div class="row" slot="hi" let:item={row}>
		<span>{row.name}</span>
	</div>
</Fillibuster>
