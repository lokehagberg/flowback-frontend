<script lang="ts">
	import type { Prediction } from "./interfaces";

	export let prediction: Prediction;
</script>

<div class="flex justify-between
">
	<span> {prediction.description}</span>
</div>
