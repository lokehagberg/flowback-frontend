<script lang="ts">
	import { _ } from 'svelte-i18n';
	export let image: File | null = null,
		label: string,
		isCover = false;
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
		<img id="image" class={`${isCover ? 'cover' : ''} avatar`} alt={label} />
	{:else}
		<img
			class="avatar"
			src="https://cdn4.iconfinder.com/data/icons/small-n-flat/24/user-alt-512.png"
			alt=""
		/>
	{/if}
	<img
		class="upload"
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
