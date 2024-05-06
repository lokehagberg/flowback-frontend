<script lang="ts">
	import { onMount } from 'svelte';

	export let src, Class: string, alt: any;
	let cachedSrc: any, mounted = false;

	onMount(() => {
		mounted = true
	})

	$: if (src !== cachedSrc && mounted)
    (async () => {
		const cached = localStorage.getItem(src);
		if (cached) {
			cachedSrc = cached;
		} else {
			const image = await fetch(src);
			const blob = await image.blob();
			const reader = new FileReader();
			reader.readAsDataURL(blob);
			reader.onloadend = () => {
				const base64data = reader.result;
                //@ts-ignore
				localStorage.setItem(src, base64data);
				cachedSrc = base64data;
			};
		}
	})();
</script>

<!-- svelte-ignore a11y-img-redundant-alt -->
<img class={Class} src={cachedSrc || src} {alt} />
