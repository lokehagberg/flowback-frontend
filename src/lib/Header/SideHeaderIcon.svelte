<script lang="ts">
	import { userStore } from '$lib/User/interfaces';
	import DefaultPFP from '$lib/assets/abstract-user-flat-4.svg';
	import { env } from '$env/dynamic/public';
	import { onThumbnailError } from '$lib/Generic/GenericFunctions';

	export let sideHeaderOpen = false;
</script>

<button
  id="side-header"
  aria-label="Side Header Toggle"
  on:click={() => (sideHeaderOpen = !sideHeaderOpen)}
>
  <img
    src={$userStore?.profile_image
      ? `${env.PUBLIC_API_URL}${$userStore?.profile_image}`
      : DefaultPFP}
    class={`w-8 rounded-full cursor-pointer ${sideHeaderOpen && 'ring-blue-500'}`}
    alt="default pfp"
    on:error={(e) => onThumbnailError(e, DefaultPFP)}
  />
</button>