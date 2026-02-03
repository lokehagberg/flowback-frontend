<script>
	import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
	import Button from './Button.svelte';
	import Fa from 'svelte-fa';
	import { onMount } from 'svelte';

	const directedGraph = {
		Delegation: ['Group', 'Dack'],
		'Delegate History': ['Delegation'],
		Poll: ['Delegate History', 'Group'],
		Group: ['Group Settings', 'Group Schedule', 'Group Kanban', 'Delegate History', 'Back'],
		'Group Settings': ['Group'],
		'Group Schedule': ['Group', 'Back'],
		'Group Kanban': ['Group', 'Back'],
		'User Settings': ['Back']
	};


	const preventChatBug = async () => {

		const a = new PopStateEvent('popstate', { state: {} });
		
		console.log(a, location.href);
		
		
	}

	const handleClick = async () => {
		history.back();
		await preventChatBug();
	}

	onMount(() => {
		preventChatBug();
	})


</script>

<Button
	onClick={handleClick}
	Class="z-[60] fixed p-3 m-4 transition-all bg-gray-200 dark:bg-darkobject hover:brightness-95 active:brightness-90"
	id="back-button"
>
	<div class="text-gray-800 dark:text-gray-200">
		<Fa icon={faArrowLeft} />
	</div>
</Button>
