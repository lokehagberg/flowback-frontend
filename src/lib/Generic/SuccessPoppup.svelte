<script lang="ts">
	import { _ } from 'svelte-i18n';

	export let show = false, message = "Task performed successfully";

	const successPoppupAnimation = () => {
		show = true;
		setTimeout(() => {
			show = false;
		}, 2500);
	};

	$: show && successPoppupAnimation();
</script>

<div class="fixed bottom-5 right-5 z-50" hidden={!show}>
	<div
		id="popup"
		class="bg-primary text-white px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3"
		class:show
	>
		{$_(message)}
	</div>
</div>

<style>
	#popup.show {
		opacity: 1;
		transform: translate-y(0);
	}
</style>
