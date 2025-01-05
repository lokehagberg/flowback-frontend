<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import CreatePoll from '$lib/Group/Creation/CreatePoll.svelte';
	import { _ } from 'svelte-i18n';
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	const goBack = () => {
		const groupId = $page.url.searchParams.get('id');
		goto(`/groups/${groupId}`);
	};
</script>

<svelte:head>
	<title>{$_('Creating a Poll')}</title>
</svelte:head>

<Layout>
	<div class="container mx-auto px-4 relative">
		<button
			class="absolute left-4 top-6 text-gray-600 hover:text-gray-800 dark:text-gray-400 dark:hover:text-gray-200"
			on:click={goBack}
		>
			<Fa icon={faArrowLeft} />
		</button>
		<!-- <h1 class="text-2xl font-semibold text-primary text-center mt-4">{$_('Create a Poll')}</h1> -->
		<div class="flex justify-center">
			<CreatePoll />
		</div>
	</div>
</Layout>
