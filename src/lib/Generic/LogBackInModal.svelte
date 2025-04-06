<script>
	import Button from './Button.svelte';
	import Modal from './Modal.svelte';
	import { _ } from 'svelte-i18n';
	import { goto } from '$app/navigation';

	export let open = false;

	const logBackIn = () => {
		localStorage.setItem(
			'sessionExpirationTime',
			// A session is set to 24 hours with "1000 * 3600 * 24"
			(new Date().getTime() + 1000 * 3600 * 24).toString()
		);

		open = false;
	};

	const logOut = () => {
		open = false;
		localStorage.removeItem('token');
		localStorage.removeItem('sessionExpirationTime');
		goto('/login');
	};
</script>

<Modal bind:open>
	<div slot="body" class="py-4 px-2 text-lg">
		{$_('Your session is about to expire, stay logged in?')}
	</div>
	<div slot="footer" class="flex justify-end gap-4">
		<Button onClick={logOut} buttonStyle="warning-light">{$_('Log Out')}</Button>
		<Button onClick={logBackIn}>{$_('Stay logged in')}</Button>
	</div>
</Modal>
