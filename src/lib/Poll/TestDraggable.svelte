<script lang="ts">
    import { onMount } from 'svelte';

	onMount(async () => {
        const obj = await import("@shopify/draggable")
        const ThingYouWant = obj.default

        
    })

  // Good to go!

</script>

<ul>
	<li>1</li>
	<li>2</li>
	<li>3</li>
</ul>
