<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';
	import Loader from '$lib/Generic/Loader.svelte';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import type { proposal } from '$lib/Poll/interface';
	import type { KPI, KPIBetProposal } from './interface';
	import { onMount } from 'svelte';

	let kpis: KPI[] = $state([]),
		loading = $state(false),
		kpiProbabilities: KPIBetProposal[] = $state([]);

	let { proposal }: { proposal: proposal } = $props();

	// TODO: Move into poll and just pass it into here.
	const getGroupKPIs = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${page.params.groupId}/kpi/list`
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not get KPIs', success: false });
			return;
		}

		kpis = (json ?? []).filter((kpi: KPI) => kpi.active);
	};

	const getProposalKPIs = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			// TODO: Make this more efficient with a bulk endpoint
			`group/${page.params.groupId}/poll/proposal/kpi/bet/list?proposal_ids=${proposal.id}`
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not get KPIs', success: false });
			return;
		}

		kpiProbabilities = json.results ?? [];
	};

	const editProposalKPI = async (kpi: KPI, value: number, selectedValue: string) => {
		const weights = kpi.values.map((v) =>
			v === 'other'
				? 0
				: v === selectedValue
					? value
					: (kpiProbabilities.find((p) => p.kpi_id === kpi.id && p.value === v)?.weight ?? 0)
		);
		const otherIndex = kpi.values.indexOf('other');
		if (otherIndex !== -1) {
			weights[otherIndex] = Math.max(0, 100 - weights.reduce((sum, weight) => sum + weight, 0));
		}
		const { res } = await fetchRequest(
			'POST',
			`group/poll/proposal/${proposal.id}/kpi/bet`,
			{
				kpi_id: kpi.id,
				values: kpi.values,
				weights
			}
		);

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not submit KPI vote',
				success: false
			});
			return;
		}

		getProposalKPIs();
	};

	onMount(() => {
		getGroupKPIs();
		getProposalKPIs();
	});
</script>

<Loader bind:loading>
	{#if kpis.length > 0}
		<div class="flex flex-col gap-6">
			<span class="text-lg font-semibold text-purple-700 dark:text-purple-300">
				{$_('KPIs')}
			</span>
			{#each kpis as kpi, kpiIndex}
				{@const totalWeight = kpi.values.filter((v) => v !== 'other').reduce(
					(sum, v) =>
						sum +
						(kpiProbabilities.find((p) => p.kpi_id === kpi.id && p.value === v)
							?.weight ?? 0),
					0
				)}
				{@const overAllocated = totalWeight > 100}
				{@const otherWeight = Math.max(0, 100 - totalWeight)}
				<div
					class="flex flex-col gap-3 p-4 rounded-xl kpi-card transition-colors duration-300
						{overAllocated
						? 'bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-800/40'
						: 'bg-purple-50 dark:bg-purple-950/30 border border-purple-100 dark:border-purple-800/40'}"
					style="animation-delay: {kpiIndex * 80}ms"
				>
					<div class="flex items-center justify-between">
						<span
							class="font-semibold text-base text-purple-900 dark:text-purple-100"
						>
							{kpi.name}
						</span>
						{#if totalWeight > 0}
							<span
								class="text-xs font-medium tabular-nums transition-colors duration-300
									{overAllocated
									? 'text-red-600 dark:text-red-400'
									: 'text-purple-500 dark:text-purple-400'}"
							>
								{totalWeight}% allocated
								{#if overAllocated}
									— exceeds 100%
								{/if}
							</span>
						{/if}
					</div>
					{#if kpi.description}
						<span
							class="text-sm text-purple-600/70 dark:text-purple-300/60 -mt-1"
							>{kpi.description}</span
						>
					{/if}

					<div class="flex flex-col gap-2">
						{#each kpi.values.filter((v) => v !== 'other') as value, i}
							{@const weight =
								kpiProbabilities.find(
									(_kpi) => _kpi.kpi_id === kpi.id && _kpi.value === value
								)?.weight ?? 0}
							<div
								aria-label="Set KPI probability for {value}"
								class="group flex items-center gap-3 w-full cursor-pointer kpi-row"
								style="animation-delay: {kpiIndex * 80 + i * 50}ms"
							>
								<span
									class="text-sm font-semibold w-8 text-right tabular-nums text-purple-700 dark:text-purple-300 shrink-0"
								>
									{value}
								</span>
								<button
									class="flex-1 h-10 bg-purple-100 dark:bg-purple-900/40 rounded-lg overflow-hidden relative group-hover:bg-purple-200/80 dark:group-hover:bg-purple-900/60 transition-colors duration-150"
									onclick={(e) => {
										// Calculate click position as percentage of button width
										const rect = e.currentTarget.getBoundingClientRect();
										const xWithinElement = e.clientX - rect.left;
										const fraction = (xWithinElement / rect.width) * 100;

										const weight = Math.round(fraction / 5) * 5; // Round to nearest 5%
										editProposalKPI(kpi, weight, value);
									}}
								>
									<div
										class="h-full rounded-lg transition-all duration-300 ease-out
											{overAllocated
											? 'bg-gradient-to-r from-red-400 to-red-500 dark:from-red-500 dark:to-red-400'
											: 'bg-gradient-to-r from-purple-400 to-purple-500 dark:from-purple-500 dark:to-purple-400'}"
										style="width: {weight}%"
									></div>
									{#if weight > 0}
										<span
											class="absolute inset-0 flex items-center px-3 text-xs font-semibold tabular-nums {weight >
											15
												? 'text-white'
												: 'text-purple-700 dark:text-purple-200'} transition-opacity duration-200"
											style="padding-left: {weight > 15
												? '0.75rem'
												: Math.max(weight, 2).toString() + '%'}"
										>
											{weight}%
										</span>
									{/if}
								</button>
							</div>
						{/each}
						<div
							aria-label="Other, remaining probability"
							class="flex items-center gap-3 w-full opacity-70 cursor-not-allowed kpi-row"
							style="animation-delay: {kpiIndex * 80 + kpi.values.length * 50}ms"
						>
							<span
								class="text-sm font-semibold w-8 text-right tabular-nums text-purple-700 dark:text-purple-300 shrink-0"
							>
								{$_('Other')}
							</span>
							<div
								class="flex-1 h-10 bg-purple-100/60 dark:bg-purple-900/20 rounded-lg overflow-hidden relative"
							>
								<div
									class="h-full rounded-lg bg-gradient-to-r from-purple-300 to-purple-400 dark:from-purple-700 dark:to-purple-600 transition-all duration-300 ease-out"
									style="width: {otherWeight}%"
								></div>
								{#if otherWeight > 0}
									<span
										class="absolute inset-0 flex items-center px-3 text-xs font-semibold tabular-nums {otherWeight >
										15
											? 'text-white'
											: 'text-purple-700 dark:text-purple-200'} transition-opacity duration-200"
										style="padding-left: {otherWeight > 15
											? '0.75rem'
											: Math.max(otherWeight, 2).toString() + '%'}"
									>
										{otherWeight}%
									</span>
								{/if}
							</div>
						</div>
					</div>
				</div>
			{/each}
		</div>
	{:else}
		<div>
			<span class="text-sm text-gray-500 dark:text-gray-400"
				>{$_(
					'No KPIs found for this group. A moderator has to add KPIs in group edit.'
				)}</span
			>
		</div>
	{/if}
</Loader>

<style>
	.kpi-card {
		animation: fadeSlideIn 0.35s ease-out both;
	}

	.kpi-row {
		animation: fadeSlideIn 0.3s ease-out both;
	}

	@keyframes fadeSlideIn {
		from {
			opacity: 0;
			transform: translateY(8px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}
</style>
