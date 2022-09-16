<script lang="ts">
	import ButtonPrimary from '$lib/Generic/ButtonPrimary.svelte';
	import Layout from '$lib/Generic/Layout.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faPaperPlane } from '@fortawesome/free-solid-svg-icons/faPaperPlane';
	import { fetchRequest } from '$lib/FetchRequest';
	import ImageUpload from '$lib/Generic/ImageUpload.svelte';
	import TextArea from '$lib/Generic/TextArea.svelte';

	let name = 'Default Name',
		description = 'Default Descritption',
		image: File,
		cover_image: File,
		direct_join = true;

	const createGroup = async () => {
		const formData = new FormData();
		
		formData.append('name', name);
		formData.append('description', description);
		formData.append('image', image);
		formData.append('cover_image', cover_image);
		formData.append('direct_join', direct_join.toString());
		formData.append('public', true)

		const res = await fetchRequest('POST', 'group/create', formData, true, false);
		console.log(res);
	};
</script>

<Layout centering={true}>
	<form
		on:submit|preventDefault={createGroup}
		class="flex items-start justify-center gap-8 mt-24 ml-8 mr-8"
	>
		<div class="bg-white p-6 shadow-xl flex flex-col gap-6 w-2/3">
			<h1 class="text-2xl">Create a Group</h1>
			<TextInput label="Title" bind:value={name} />
			<TextArea label="Description" bind:value={description}/>
			<ImageUpload bind:image label="Upload Image" />
			<ImageUpload bind:image={cover_image} label="Upload Cover Image" isCover={true} />
			<fieldset>
				<h1 class="text-left text-sm">Allow direct join?</h1>
				<div class="mt-2">
					<label>
						No
						<input
							type="radio"
							name="direct_join"
							checked={!direct_join}
							on:change={() => (direct_join = false)}
						/>
					</label>
					<label class="ml-4">
						Yes
						<input
							type="radio"
							name="direct_join"
							checked={direct_join}
							on:change={() => (direct_join = true)}
						/>
					</label>
				</div>
			</fieldset>
			<ButtonPrimary type="submit"
				><div class="flex justify-center gap-3 items-center">
					<Fa icon={faPaperPlane} />Create Group
				</div>
			</ButtonPrimary>
		</div>
	</form>
</Layout>
