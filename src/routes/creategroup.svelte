<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { fetchRequest } from '$lib/FetchRequest';

	let name = 'Default Name';
	let description = 'Default Descritption';
	let image:any;
	let cover_image:any;
	let direct_join = false;

	const createGroup = async () => {
		const res = await fetchRequest('POST', 'group/create', {
			name,
			description,
			image,
			cover_image,
			direct_join
		});
		console.log(res)
	};
</script>

<Layout centering={true}>
	<form
		on:submit|preventDefault={createGroup}
		class="flex items-start justify-center gap-8 mt-24 ml-8 mr-8"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">Create a Group</h1>
			<TextInput label="Title" />
			<TextInput label="Description" />
			<!-- <input type="file" alt="image" value={cover_image} />
			<input type="file" alt="image" value={image} /> -->
			<ButtonPrimary type="submit"
				><div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane} />Create Group
				</div>
			</ButtonPrimary>
		</div>
	</form>
</Layout>
