<script lang="ts">
	import Button from './Button.svelte';

	export let action = () => {},
		loopTime = 1000;
	let interval: any,
		toggled = false;

	const repeatAction = () => {
        action();
		interval = setInterval(() => {
			action();
		}, loopTime);
	};
</script>

<Button
	action={toggled
		? () => {
				toggled = false;
				clearInterval(interval);
		  }
		: () => {
				toggled = true;
				repeatAction();
		  }}
>
	Toggle
</Button>
