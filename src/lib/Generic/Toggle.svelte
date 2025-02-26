<script lang="ts">
	export let checked: boolean = false,
		onInput = (checked: boolean) => {};
</script>

<label class="switch">
	<input type="checkbox" bind:checked on:input={() => onInput(!checked)} />
	<span class="slider round" />
</label>

<style>
	.switch {
		position: relative;
		display: inline-block;
		width: 50px;
		height: 28px;
	}

	.switch input {
		opacity: 0;
		width: 0;
		height: 0;
	}

	/* The slider */
	.slider {
		position: absolute;
		cursor: pointer;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: #ccc;
		-webkit-transition: 0.4s;
		transition: 0.4s;
	}

	.slider:before {
		position: absolute;
		content: '';
		height: 20px;
		width: 20px;
		left: 4px;
		bottom: 4px;
		background-color: white;
		-webkit-transition: 0.4s;
		transition: 0.4s;
	}

	input:checked + .slider {
		background-color: #2196f3;
	}

	input:focus + .slider {
		box-shadow: 0 0 1px #2196f3;
	}

	input:checked + .slider:before {
		-webkit-transform: translateX(22px);
		-ms-transform: translateX(22px);
		transform: translateX(22px);
	}

	.slider.round {
		border-radius: 28px;
	}

	.slider.round:before {
		border-radius: 50%;
	}
</style>
