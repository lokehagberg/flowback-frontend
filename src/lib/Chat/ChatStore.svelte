<script context="module">
	import { writable } from 'svelte/store';

	// Store to track if the new chat is open
	export const isChatOpen = writable(false);

	// Store to track if the old chat is open
	export const isOldChatOpen = writable(false);

	// Store to hold the identifier of the person being talked to.
	// This can be an object or a simple value as per your application needs.
	export const chatPartner = writable(0);
</script>
