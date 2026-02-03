<script lang="ts">
	import { env } from '$env/dynamic/public';
	import Verify from '$lib/Login/Verify.svelte';
	import Logo from '$lib/assets/Logo.png';
	import Reforum from '$lib/assets/ReforumTransparent.png';
</script>

<div class="dark:!bg-darkbackground bg-purple-50 h-[100vh] flex flex-col items-center">
	<div class="mt-16">
		<img
			src={env.PUBLIC_LOGO === 'REFORUM' ? Reforum : Logo}
			class="w-[300px]"
			alt="flowback logo"
		/>
	</div>
	<div
		class="bg-white dark:bg-darkobject dark:text-darkmodeText mt-12 rounded shadow-lg w-full max-w-[600px]"
	>
		<div>
			<Verify />
		</div>
	</div>
</div>
