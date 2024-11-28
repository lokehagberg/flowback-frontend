<script>
	import Layout from '$lib/Generic/Layout.svelte';
    import { _ } from 'svelte-i18n';
</script>

<Layout centered>
	<div class="bg-white p-6 shadow w-full text-left">
		<h1 class="text-xl font-semibold text-primary text-left">{$_("Automate")}</h1>
		<p>
			{$_(`Sometimes we have limited time and cannot participate fully, but still want to contribute.
			Reformum has a number of functions to automate parts of your engagement when you cannot
			participate yourself.`)}
		</p>
	</div>
	<div class="flex">
		<div class="bg-white p-6 shadow" />

		<div class="bg-white p-6 shadow" />
	</div>
</Layout>
