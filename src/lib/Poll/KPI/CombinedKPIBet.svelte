<script lang="ts">
	import { page } from '$app/state';
	import { fetchRequest } from '$lib/FetchRequest';
	import { ErrorHandlerStore } from '$lib/Generic/ErrorHandlerStore';
	import Loader from '$lib/Generic/Loader.svelte';
	import type { proposal } from '$lib/Poll/interface';
	import { _ } from 'svelte-i18n';
	import { onMount } from 'svelte';
	import type { CombinedBet } from './interface';

	let { proposal }: { proposal: proposal } = $props();

	let loading = $state(false),
		combinedBets: CombinedBet[] = $state([]);

	let groupedBets = $derived(
		combinedBets.reduce<
			Record<
				number,
				{ name: string; description: string | null; bets: CombinedBet[] }
			>
		>((acc, bet) => {
			if (!acc[bet.kpi_id]) {
				acc[bet.kpi_id] = {
					name: bet.kpi_name,
					description: bet.kpi_description,
					bets: []
				};
			}
			acc[bet.kpi_id].bets.push(bet);
			return acc;
		}, {})
	);

	const getCombinedKPIBets = async () => {
		if (!proposal?.id) return;

		loading = true;
		const { res, json } = await fetchRequest(
			'GET',
			`group/${page.params.groupId}/poll/proposal/kpi/list?proposal_ids=${proposal.id}`
		);
		loading = false;

		if (!res.ok) {
			ErrorHandlerStore.set({
				message: 'Could not get combined KPI bets',
				success: false
			});
			return;
		}

		combinedBets = json?.results ?? json ?? [];
	};

	onMount(() => {
		getCombinedKPIBets();
	});
</script>

<Loader bind:loading>
	{#if combinedBets.length > 0}
		<div class="flex flex-col gap-5">
			<span class="text-lg font-semibold text-purple-700 dark:text-purple-300">
				{$_('Combined Bets')}
			</span>

			{#each Object.entries(groupedBets) as [kpiId, group], kpiIndex}
				{@const maxBet = Math.max(
					...group.bets.map((b) => Number(b.combined_bet) || 0),
					0.01
				)}
				<div
					class="flex flex-col gap-3 p-4 rounded-xl bg-purple-50 dark:bg-purple-950/30 border border-purple-100 dark:border-purple-800/40 kpi-card"
					style="animation-delay: {kpiIndex * 80}ms"
				>
					<span
						class="font-semibold text-base text-purple-900 dark:text-purple-100"
					>
						{group.name}
					</span>
					{#if group.description}
						<span
							class="text-sm text-purple-600/70 dark:text-purple-300/60 -mt-1"
						>
							{group.description}
						</span>
					{/if}

					<div class="flex flex-col gap-1.5">
						{#each group.bets as bet, i}
							<!-- TODO: Only one const needed -->
							{@const betValue = Number(bet.combined_bet) || 0}
							{@const barWidth = (betValue / maxBet) * 100}
							<div
								class="flex items-center gap-3 w-full kpi-row"
								style="animation-delay: {kpiIndex * 80 + i * 40}ms"
							>
								<span
									class="text-sm font-semibold w-10 text-right tabular-nums text-purple-700 dark:text-purple-300 shrink-0"
								>
									{bet.value}
								</span>

								<div
									class="flex-1 h-8 bg-purple-100/70 dark:bg-purple-900/30 rounded-lg overflow-hidden relative"
								>
									{#if bet.combined_bet !== null}
										<div
											class="h-full rounded-lg transition-all duration-500 ease-out
												{bet.outcome
												? 'bg-gradient-to-r from-emerald-400 to-emerald-500 dark:from-emerald-500 dark:to-emerald-400'
												: 'bg-gradient-to-r from-purple-400 to-purple-500 dark:from-purple-500 dark:to-purple-400'}"
											style="width: {betValue.toFixed(1) * 100}%"
										></div>
										<span
											class="absolute inset-0 flex items-center text-xs font-semibold tabular-nums
												{barWidth > 25 ? 'text-white px-3' : 'text-purple-700 dark:text-purple-200'}"
											style="padding-left: {barWidth > 25
												? '0.75rem'
												: `max(${barWidth}% + 0.5rem, 3rem)`}"
										>
											{betValue.toFixed(1) * 100}%
										</span>
									{:else}
										<span
											class="absolute inset-0 flex items-center px-3 text-xs text-purple-400 dark:text-purple-500 italic"
										>
											{$_('No data')}
										</span>
									{/if}
								</div>

								{#if bet.outcome}
									<span
										class="text-xs font-bold text-emerald-600 dark:text-emerald-400 shrink-0"
									>
										{$_('Outcome')}
									</span>
								{/if}
							</div>
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
