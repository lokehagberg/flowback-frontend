<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/state';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import Button from '$lib/Generic/Button.svelte';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import Modal from '$lib/Generic/Modal.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import Toggle from '$lib/Generic/Toggle.svelte';
	import Fa from 'svelte-fa';
	import { faTrash } from '@fortawesome/free-solid-svg-icons';

	interface KPI {
		name: string;
		description: string;
		active: boolean;
		values: number[];
		id: number;
	}

	let kpis: KPI[] = $state([]),
		kpiName = $state(''),
		kpiDescription = $state(''),
		kpiValues = $state(''),
		loading = $state(false),
		selectedKPI: KPI | null = $state(null),
		areYouSureModal = $state(false);

	const getKPIs = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${page.params.groupId}/kpi/list`
		);

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not get KPIs', success: false });
			loading = false;
			return;
		}

		kpis = json;
		loading = false;
	};

	const addKPI = async (e: SubmitEvent) => {
		e.preventDefault();
		loading = true;

		const values = kpiValues.split(',');

		let toSend: any = {
			name: kpiName,
			values
		};

		if (kpiDescription) toSend.description = kpiDescription;

		const { res } = await fetchRequest(
			'POST',
			`group/${page.params.groupId}/kpi/create`,
			toSend
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not add KPI', success: false });
			return;
		}

		getKPIs();
		kpiName = '';
		kpiDescription = '';
		kpiValues = '';
		ErrorHandlerStore.set({ message: 'Successfully added KPI', success: true });
	};

	const removeKPI = async (kpi: KPI) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/kpi/${kpi.id}/delete`);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not delete KPI',
				success: false
			});
		}

		getKPIs();
		areYouSureModal = false;
		loading = false;
	};

	const toggleKPI = async (kpi: KPI) => {
		loading = true;
		const { res } = await fetchRequest('POST', `group/kpi/${kpi.id}/update`, {
			active: !kpi.active
		});

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not update KPI',
				success: false
			});

			kpi.active = !kpi.active;
			return;
		}

		getKPIs();
	};

	getKPIs();
</script>

<Loader bind:loading>
	<form onsubmit={addKPI} class="pb-4 flex flex-col gap-2">
		<TextInput
			label="Name"
			max={50}
			bind:value={kpiName}
			required
			Class="flex-1"
		/>
		<TextArea
			label="Description"
			max={500}
			bind:value={kpiDescription}
			inputClass="max-h-[15rem]"
		/>
		<TextInput
			label="Values (comma-separated integers)"
			bind:value={kpiValues}
			required
			Class="flex-1"
		/>
		<Button
			disabled={loading}
			type="submit"
			Class="w-1/5 h-8 flex items-center justify-center"
			buttonStyle="primary-light"
			label="Add"
		/>
	</form>

	<div class="flex flex-col justify-between gap-2 py-2">
		{#each kpis as kpi}
			<div class="flex justify-between items-center">
				<div>
					<p>{kpi.name}</p>
					{#if kpi.description}
						<p class="text-sm text-gray-500">{kpi.description}</p>
					{/if}
					<p class="text-xs text-gray-400">
						Values: {kpi.values?.join(', ')}
					</p>
				</div>
				<div class="flex gap-2 items-center ml-auto">
					<Toggle bind:checked={kpi.active} onInput={() => toggleKPI(kpi)} />
					<button
						class="text-red-500 p-2 pl-4 text-lg cursor-pointer"
						disabled={loading}
						onclick={() => {
							areYouSureModal = true;
							selectedKPI = kpi;
						}}
					>
						<Fa icon={faTrash} />
					</button>
				</div>
			</div>
		{/each}
	</div>
</Loader>

<Modal bind:open={areYouSureModal}>
	<div slot="header">{$_('Are you sure?')}</div>
	<div slot="body">
		<span>{$_('You are removing')}: {selectedKPI?.name}</span>
	</div>
	<div slot="footer" class="flex gap-2">
		<Button
			disabled={loading}
			onClick={() => selectedKPI && removeKPI(selectedKPI)}
			Class="bg-red-500 w-1/2">{$_('Yes')}</Button
		>
		<Button
			disabled={loading}
			onClick={() => (areYouSureModal = false)}
			Class="bg-gray-600 w-1/2">{$_('No')}</Button
		>
	</div>
</Modal>
