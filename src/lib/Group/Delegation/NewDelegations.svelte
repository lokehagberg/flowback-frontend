<script lang="ts">
	import Loader from '$lib/Generic/Loader.svelte';
	import type { Tag } from '../interface';
	import { page } from '$app/stores';
	import { getTags } from '../functions';
	import { onMount } from 'svelte';
	import Fa from 'svelte-fa';
	import { faAngleDown, faAngleRight } from '@fortawesome/free-solid-svg-icons';
	import { fetchRequest } from '$lib/FetchRequest';
	import { delegation as delegationLimit } from '../../Generic/APILimits.json';
	import type { Delegate, DelegatePool } from './interfaces';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';
	import { delegate } from '$lib/Blockchain/javascript/delegationsBlockchain';

	let loading = false,
		tags: Tag[] = [],
		delegates: Delegate[] = [],
		selectedTag: Tag,
		value:number|null,
		resetValue = () => {}

	const getTagsLocal = async () => {
		loading = true;
		tags = await getTags($page.params.groupId);
		// if (!tags) poppup = { message: 'Could not get poppups', success: false };
		loading = false;
	};

	const getDelegatePools = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegate/pools?limit=${delegationLimit}`
		);

		if (!res.ok) return;

		delegates = json.results.map((delegatePool: any) => {
			return { ...delegatePool.delegates[0].group_user, pool_id: delegatePool.id };
		});

		loading = false;
	};

	const createDelegateRelation = async (delegate_pool_id: number | string) => {
		delegate_pool_id = Number(delegate_pool_id);

		loading = true;
		const { res } = await fetchRequest('POST', `group/${$page.params.groupId}/delegate/create`, {
			delegate_pool_id
		});

		loading = false;
		if (!res.ok) return;

		delegates[
			delegates.findIndex((delegate) => delegate.pool_id === delegate_pool_id)
		].isInRelation = true;
	};

	const saveDelegation = async () => {
		loading = true;
		let toSendDelegates = delegates.map((delegate) =>
			delegate?.tags?.length !== undefined
				? {
						delegate_pool_id: delegate.pool_id,
						tags: delegate.tags.map(({ id }) => id)
				  }
				: null
		);

		toSendDelegates = toSendDelegates.filter(delegate => delegate !== null)

		const { res } = await fetchRequest(
			'POST',
			`group/${$page.params.groupId}/delegate/update`,
			toSendDelegates
		);

		// if (res.ok) poppup = { message: 'Success', success: true };
		loading = false;
	};

	const changeDelegation = (delegate_id: number, tag: Tag) => {
		console.log(delegates, " DE LE ET");
		const delegateOld = delegates.find((delegate) =>
			delegate.tags.find((_tag) => _tag.id === tag.id)
		);
		let delegateNew = delegates.find((delegate) => (delegate.id = delegate_id));
		if (!delegateNew) return;

		if (delegateOld) delegateOld.tags = delegateOld?.tags.filter((_tag: any) => _tag.id !== tag.id);
		if (delegateOld?.id === delegateNew.id) {
			delegates = delegates;
			return;
		}

		//@ts-ignore
		delegateNew.tags.push(tag);
		delegates = delegates;
	};

	const getDelegateRelations = async () => {
		loading = true;
		const { json, res } = await fetchRequest(
			'GET',
			`group/${$page.params.groupId}/delegates?limit=${delegationLimit}`
		);

		loading = false;
		if (!res.ok) {
			// poppup = { message: 'Could not get delegates', success: false };
			return [];
		}

		return json.results;
	};

	const setDelegators = async () => {
		const delegateRelations: DelegatePool[] = await getDelegateRelations();

		delegateRelations.forEach((relation) => {
			delegates.map((delegate) => {
				if (delegate.pool_id === relation.delegate_pool_id) {
					relation.tags.map((tag) => {
						tag.active = true;
						tag.tag_name = tag.name;
					});
					//@ts-ignore
					delegate.tags = relation.tags;
				}
			});
		});

		delegates = delegates;

		console.log(delegates, tags, selectedTag);
	};

	const handleChangeTag = async (delegate_id: number, tag: Tag) => {
		await createDelegateRelation(delegate_id);
		await changeDelegation(delegate_id, tag);
		saveDelegation();
	};

	const handleTagChange = () => {
		resetValue();
		
	}

	onMount(async () => {
		await getTagsLocal();
		await getDelegatePools();
		setDelegators();
	});

	$: if (selectedTag) handleTagChange();
</script>

<Loader bind:loading>
	<div class="delegation-grid gap-4">
		<div class="bg-white p-4">
			{#each tags as tag}
				<div
					on:keydown={() => (selectedTag = tag)}
					on:click={() => (selectedTag = tag)}
					role="button"
					tabindex="0"
					class="text-primary font-bold flex items-center justify-between cursor-pointer"
				>
					{tag.name}
					<Fa icon={faAngleRight} />
				</div>
			{/each}
		</div>
		<div class="bg-white p-4">
			{#if selectedTag}
				<span class="text-primary font-bold text-2xl">{selectedTag.name}</span>
				<RadioButtons2
					radioSide="right"
					Class="w-full cursor-pointer"
				  	ClassInner="w-full flex justify-between cursor-pointer" 
					onChange={(e) => {
						//@ts-ignore
						handleChangeTag(e, selectedTag);
					}}
					name="delegation-radio"
					labels={delegates.map((delegate) => delegate.pool_id.toString())}
					values={delegates.map((delegate) => delegate.user.username)}
					bind:value
					bind:resetValue
				/>
			{:else}
				<span class="text-primary font-bold text-2xl">Select Tag</span>
			{/if}
		</div>
	</div>
</Loader>

<style>
	.delegation-grid {
		display: grid;
		grid-template-columns: 0.8fr 1fr;
	}
</style>
