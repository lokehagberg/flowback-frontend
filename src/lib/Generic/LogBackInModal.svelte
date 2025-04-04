<script>
	import Button from './Button.svelte';
	import Modal from './Modal.svelte';
	import { _ } from 'svelte-i18n';

	export let open = false;

	const logBackIn = () => {
		localStorage.setItem(
			'sessionExpirationTime',
			//A session is set to 24 hours with "1000 * 3600 * 24"
			(new Date().getTime() + 1000 * 3600 * 24).toString()
		);

		open = false;
	};
</script>

<Modal bind:open>
	<div slot="body">{$_('Your session is about to expire, log back in?')}</div>

	<div slot="footer"><Button onClick={logBackIn}>Yes</Button></div>
</Modal>
