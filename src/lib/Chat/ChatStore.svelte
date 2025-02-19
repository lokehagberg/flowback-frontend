<script context="module">
	import { writable } from 'svelte/store';

	// Store to track if the chat is open (true) or closed (false)
	export const isChatOpen = writable(false);

	// Store to hold the identifier of the person being talked to.
	// This can be an object or a simple value as per your application needs.
	export const chatPartner = writable(0);
</script>
