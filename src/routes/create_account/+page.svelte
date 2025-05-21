<script lang="ts">
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";

	onMount(() => {
		const email = "example@example.com"; // Replace with actual email value
		const verification_code = "123456"; // Replace with actual verification code
		goto(`login?email=${encodeURIComponent(email)}&verification_code=${encodeURIComponent(verification_code)}`);
	});
</script>
