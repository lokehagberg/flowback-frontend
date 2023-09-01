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
    /* Sources for further knowledge:
    https://support.google.com/analytics/answer/9976101
    https://support.google.com/tagmanager/answer/10718549
    https://www.youtube.com/watch?v=4lKkRD-xVMk&ab_channel=LovesData
    https://developers.google.com/tag-platform/tag-manager/templates/consent-apis
    */
	const denyCookies = () => {
		hasClicked = true;
		localStorage.setItem('cookies-consent', 'false');
	};
</script>

<div class="bg-white p-6 fixed bottom-3 dark:bg-darkbackground dark:text-darkmodeText left-1/2 -translate-x-1/2 border-gray-200 shadow z-50" class:hidden={hasClicked}>
	<span
		>{$_('We use cookies to improve the experience of Flowback')}
	</span>
	<Button action={acceptCookies} Class="ml-2">{$_('Ok')}</Button>
</div>
