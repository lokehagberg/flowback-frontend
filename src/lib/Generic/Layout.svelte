<script>
	import Chat from '$lib/Chat/Chat.svelte';
	import Header from '$lib/Header/Header.svelte';
	import Cookies from './Cookies.svelte';
	export let centering = false;
</script>

<Header />

<Chat />

<div class={`${centering ? 'flex justify-center flex-col items-center' : ''}`}>
	<slot />
</div>
<Cookies />
