<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faBars } from '@fortawesome/free-solid-svg-icons/faBars';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';

	export let title:string
	export let description:string
</script>

<div class="flex items-center bg-white gap-8 p-4">
	<div><Fa icon={faBars} /></div>
	<div>
		<h1 class="text-lg text-left">{title}</h1>
		<p class="text-sm">
			{description}
		</p>
	</div>
	<div>
		<div><Fa icon={faArrowUp} /></div>
		<div><Fa icon={faArrowDown} /></div>
	</div>
</div>

