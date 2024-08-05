<script lang="ts">
	import { _ } from 'svelte-i18n';
	import type { poppup } from './Poppup';
	import Fa from 'svelte-fa';
	import { faCheckCircle } from '@fortawesome/free-solid-svg-icons';

	export let poppup: poppup | null;

	let show = true,
		currentPoppup: NodeJS.Timeout;

	$: poppup && successPoppupAnimation();

	const successPoppupAnimation = () => {
		show = true;
		// clearTimeout(currentPoppup);
		// currentPoppup = setTimeout(() => {
		// 	show = false;
		// 	poppup = null;
		// }, 7000);
	};
</script>

{#if poppup?.message}
	<div class="bg-white fixed bottom-5 right-5 z-50" hidden={!show}>
		<div
			id="popup"
			class={`flex gap-2 items-center px-4 py-2 rounded-md shadow-md opacity-0 transition-opacity duration-300 transform translate-y-3`}
			class:show
		>
			<Fa icon={faCheckCircle} color={poppup.success ? 'green' : 'red'} />
			{$_(poppup.message)}
		</div>
	</div>
{/if}

<style>
	#popup.show {
		opacity: 1;
		transform: translate-y(0);
	}
</style>
