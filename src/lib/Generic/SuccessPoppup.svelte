<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let show = false;

	const successPoppupAnimation = () => {
		show = true;
		setTimeout(() => {
			show = false;
		}, 1000);
	};

	$: show && successPoppupAnimation();
</script>

<div class="fixed bottom-5 right-5 z-50">
	<div
		id="popup"
		class="bg-green-500 text-white px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3"
		class:show
	>
		{$_('Task performed successfully!')}
	</div>
</div>

<style>
	#popup.show {
		opacity: 1;
		transform: translate-y(0);
	}
</style>
