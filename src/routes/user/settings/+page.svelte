<script lang="ts">
	import Layout from '$lib/Generic/Layout.svelte';
	import Fa from 'svelte-fa';
	import { faUser, faBell, faPieChart } from '@fortawesome/free-solid-svg-icons';

	let selectedPage: 'profile' | 'notifications' | 'poll-process' = 'profile';
</script>

<Layout centered>
	<div class="flex mt-6 gap-6">
		<div class="bg-white w-[300px] p-6">
			<h1 class="text-xl text-left text-primary font-bold">Settings</h1>
			<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
			<!-- svelte-ignore a11y-click-events-have-key-events -->
			<ul>
				<li on:click={() => (selectedPage = 'profile')} class="flex items-center gap-2">
					<Fa icon={faUser} />Profile
				</li>
				<li on:click={() => (selectedPage = 'notifications')} class="flex items-center gap-2">
					<Fa icon={faBell} />Notification
				</li>
				<li on:click={() => (selectedPage = 'poll-process')} class="flex items-center gap-2">
					<Fa icon={faPieChart} />Poll Process
				</li>
			</ul>
		</div>
		<div class="bg-white p-6 w-[400px]">
            <ul>
                {#if selectedPage === 'profile'}
                <li>one</li>
                {:else if selectedPage === 'notifications'}
                <li>two</li>
                {:else if selectedPage === 'poll-process'}
                <li>three</li>
                {/if}

            </ul>
            
            </div>
	</div>
</Layout>
