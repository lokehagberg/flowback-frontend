<script lang="ts">
	import { _ } from 'svelte-i18n';
	import Button from './Button.svelte';
	import { onMount } from 'svelte';

	let hasClicked = true;

    onMount(() => {
        hasClicked = Boolean(localStorage.getItem('cookies-consent'))
    })

	const acceptCookies = () => {
		hasClicked = true;
		localStorage.setItem('cookies-consent', 'true');
	};

	const denyCookies = () => {
		hasClicked = true;
		localStorage.setItem('cookies-consent', 'false');
	};
</script>

<div class="bg-white p-6 fixed bottom-3 left-1/2 -translate-x-1/2 w-3/4" class:hidden={hasClicked}>
	<span
		>{$_('We use cookies to improve the experience of Flowback. Do you consent to cookies?')}
	</span>
	<Button action={acceptCookies}>{$_('Yes')}</Button>
	<Button action={denyCookies}>{$_('No')}</Button>
</div>
