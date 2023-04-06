<script lang="ts">
	import Fa from 'svelte-fa/src/fa.svelte';
	import { _ } from 'svelte-i18n';
	export let image: File | null = null,
		label: string,
		isCover = false,
		icon:any;
	let fileinput: HTMLInputElement;

	const onFileSelected = (e: any) => {
		const files: File[] = Array.from(e.target.files);
		image = files[0];
	};
</script>

<!-- on:change={() => {
				const imgtag = document.getElementById("image");
				const fr = new FileReader();
				fr.onload = () => {
					if (imgtag)
					imgtag?.src = event.target.result;
				};
			}} -->
<div class="image-upload">
	<h1 class="text-left text-sm w-full">{$_(label)}</h1>

	{#if image}
		<img id="image" class={`${isCover ? 'cover' : ''} avatar`} alt={$_(label)} />
	{:else}
		<!-- <img
			class="avatar"
			src="https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png"
			alt=""
		/> -->
		<Fa icon={icon} size={'5x'} class="mt-6"/>
	{/if}
	<img
		class="upload mt-4"
		src="https://static.thenounproject.com/png/625182-200.png"
		alt=""
		on:click={() => {
			fileinput.click();
		}}
	/>
	<div
		class="chan"
		on:click={() => {
			fileinput.click();
		}}
	>
		{$_('Choose Image')}
	</div>
	<input
		style="display:none"
		type="file"
		accept=".jpg, .jpeg, .png"
		on:change={(e) => onFileSelected(e)}
		bind:this={fileinput}
	/>
</div>

<style>
	.image-upload {
		display: flex;
		align-items: center;
		justify-content: center;
		flex-flow: column;
	}

	.upload {
		display: flex;
		height: 50px;
		width: 50px;
		cursor: pointer;
	}

	.avatar {
		display: flex;
		height: 10rem;
		width: 10rem;
	}

	.cover {
		width: 100%;
	}
</style>
