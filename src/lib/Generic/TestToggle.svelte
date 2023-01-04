<script lang="ts">
	import ButtonPrimary from './ButtonPrimary.svelte';

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

<ButtonPrimary
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
</ButtonPrimary>
