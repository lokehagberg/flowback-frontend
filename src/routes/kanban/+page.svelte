<script>
	import {test} from '$lib/Blockchain/javascript/test.js';
	import Button from '$lib/Generic/Button.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import Kanban from '$lib/Group/Kanban/Kanban.svelte';
	import { _ } from 'svelte-i18n';
</script>

<svelte:head>
	<title>My Kanban</title>
</svelte:head>

<!-- This is for the personal kanban page. <Kanban /> is also used in groups, so this file is not reduntant -->
<Layout centering={true}>
	<Kanban type="home" Class="w-[1000px]" />
</Layout>

<Button action={test}>Make Wallet</Button>
