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

    //TODO: Maybe implement this in the future (using google analytics)
	const denyCookies = () => {
		hasClicked = true;
		localStorage.setItem('cookies-consent', 'false');
	};
</script>

<div class="bg-white p-6 fixed bottom-3 left-1/2 -translate-x-1/2 border-gray-200 shadow z-50" class:hidden={hasClicked}>
	<span
		>{$_('We use cookies to improve the experience of Flowback')}
	</span>
	<Button action={acceptCookies} Class="ml-2">{$_('Ok')}</Button>
</div>
