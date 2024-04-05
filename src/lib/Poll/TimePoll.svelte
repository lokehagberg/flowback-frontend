<script lang="ts">
	import Button from '$lib/Generic/Button.svelte';
	import { faCheck, faCross, faX } from '@fortawesome/free-solid-svg-icons';
	import Fa from 'svelte-fa';
</script>

<div class="w-[80px] ">
	<div class="text-center">SUN</div>
	<div class="font-bold text-center">6</div>
	<div class="text-center">12:00</div>

	<div class="flex flex-col items-center">
		<Button Class="flex justify-center w-[90%]"><Fa icon={faCheck}/></Button>
		<Button Class="flex justify-center w-[90%]"><Fa icon={faX}/></Button>
	</div>
</div>
