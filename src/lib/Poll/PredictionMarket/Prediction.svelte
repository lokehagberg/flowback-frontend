<script lang="ts">
	export let prediction: any;
</script>

<div class="flex justify-between
">
	<span> {prediction.title}</span>
	<span> {prediction.description}</span>
	<div>{prediction.prediction_score} % </div>
</div>
