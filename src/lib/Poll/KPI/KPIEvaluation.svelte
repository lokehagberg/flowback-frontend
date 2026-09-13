<script lang="ts">
	import { fetchRequest } from '$lib/FetchRequest';
	import Loader from '$lib/Generic/Loader.svelte';
	import { page } from '$app/state';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import { _ } from 'svelte-i18n';
	import type { KPI, KPIEvaluation } from './interface';
	import { onMount } from 'svelte';
	import type { proposal } from '../interface';

	let loading = $state(false),
		kpis: KPI[] = $state([]),
		kpiEvaluations: KPIEvaluation[] = $state([]);

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

	const getKPIVoteList = async () => {
		loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${page.params.groupId}/poll/proposal/kpi/vote/list?proposal_ids=${proposal.id}`
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({ message: 'Could not get KPIs', success: false });
			return;
		}
		kpiEvaluations = json.results ?? [];
	};

	const evaluateKPI = async (kpi: KPI, value: string) => {
		loading = true;
		const { res, json } = await fetchRequest(
			'POST',
			`group/poll/proposal/${proposal.id}/kpi/vote`,
			{
				kpi_id: kpi.id,
				vote: value
			}
		);

		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not submit KPI evaluation',
				success: false
			});
			return;
		}

		getKPIVoteList();
	};
	onMount(() => {
		getGroupKPIs();
		getKPIVoteList();
	});
</script>

<Loader bind:loading>
	{#if kpis.length > 0}
		<div class="flex flex-col gap-6">
			<span class="text-lg font-semibold text-purple-700 dark:text-purple-300">
				{$_('KPIs')}
			</span>
			{#each kpis as kpi, kpiIndex}
				<div
					class="flex flex-col gap-3 p-4 rounded-xl bg-purple-50 dark:bg-purple-950/30 border border-purple-100 dark:border-purple-800/40 kpi-card"
					style="animation-delay: {kpiIndex * 80}ms"
				>
					<span
						class="font-semibold text-base text-purple-900 dark:text-purple-100"
					>
						{kpi.name}
					</span>
					{#if kpi.description}
						<span
							class="text-sm text-purple-600/70 dark:text-purple-300/60 -mt-1"
							>{kpi.description}</span
						>
					{/if}

					<div class="flex flex-wrap gap-2">
						{#each kpi.values as value, i}
							{@const selected = !!kpiEvaluations.find(
								(e) => e.vote === value && e.kpi_id === kpi.id
							)}
							<button
								onclick={() => evaluateKPI(kpi, value)}
								class="h-10 min-w-[3rem] px-4 rounded-lg text-sm font-semibold tabular-nums transition-all duration-200 cursor-pointer kpi-eval-btn
									{selected
									? 'bg-purple-600 text-white shadow-md shadow-purple-300 dark:shadow-purple-900 scale-105'
									: 'bg-purple-100 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 hover:bg-purple-200 dark:hover:bg-purple-800/50'}"
								style="animation-delay: {kpiIndex * 80 + i * 50}ms"
							>
								{value}
							</button>
						{/each}
					</div>
				</div>
			{/each}
		</div>
	{/if}
</Loader>

<style>
	.kpi-card {
		animation: fadeSlideIn 0.35s ease-out both;
	}

	.kpi-eval-btn {
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
