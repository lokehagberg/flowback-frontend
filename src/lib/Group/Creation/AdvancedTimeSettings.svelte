<script lang="ts">
	import { DateInput } from 'date-picker-svelte';
	import { _ } from 'svelte-i18n';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	import TimelineTemplate from './TimelineTemplate.svelte';
	import type { pollType, template } from './interface';
	import MonthView from '$lib/Generic/Schedules/MonthView.svelte';
	import RadioButtons2 from '$lib/Generic/RadioButtons2.svelte';

	export let selected_poll: pollType,
		advancedTimeSettings = false,
		start_date = new Date(),
		area_vote_end_date = new Date(),
		proposal_end_date = new Date(),
		prediction_statement_end_date = new Date(),
		prediction_bet_end_date = new Date(),
		delegate_vote_end_date = new Date(),
		vote_end_date = new Date(),
		end_date = new Date();

	let daysBetweenPhases = 1,
		calendarView = '1';

	$: (daysBetweenPhases || !daysBetweenPhases) && changeDaysBetweenPhases();

	const handleSelectTemplate = (template: template) => {
		const now = new Date().getTime();
		start_date = new Date();
		start_date.setHours(0, 0, 0, 0);

		area_vote_end_date = new Date(now + template.area_vote_time_delta);
		proposal_end_date = new Date(area_vote_end_date.getTime() + template.proposal_time_delta);
		prediction_statement_end_date = new Date(
			proposal_end_date.getTime() + template.prediction_statement_time_delta
		);
		prediction_bet_end_date = new Date(
			prediction_statement_end_date.getTime() + template.prediction_bet_time_delta
		);
		delegate_vote_end_date = new Date(
			prediction_bet_end_date.getTime() + template.delegate_vote_time_delta
		);
		vote_end_date = new Date(delegate_vote_end_date.getTime() + template.vote_time_delta);
		end_date = new Date(vote_end_date.getTime() + template.end_time_delta);
	};

	const changeDaysBetweenPhases = () => {
		const now = new Date();
		start_date = new Date();
		start_date.setHours(0, 0, 0, 0);

		//For debug purposes this puts one minute delay between each phase.
		if (daysBetweenPhases === 0) {
			area_vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			proposal_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			prediction_statement_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			prediction_bet_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			delegate_vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			vote_end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			end_date = new Date(now.setMinutes(now.getMinutes() + 1));
			//For users to select over multiple days
		} else {
			area_vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			proposal_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			prediction_statement_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			prediction_bet_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			delegate_vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			vote_end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
			end_date = new Date(now.setDate(now.getDate() + daysBetweenPhases));
		}
	};
</script>

{#if advancedTimeSettings}
	<div>
		<RadioButtons2
			name="advancedTimeSettingChoice"
			bind:value={calendarView}
			values={['1', '0']}
			labels={['Calendar', 'List']}
		/>
		{#if calendarView === '1'}
			<MonthView
				bind:start_date
				bind:area_vote_end_date
				bind:proposal_end_date
				bind:prediction_statement_end_date
				bind:prediction_bet_end_date
				bind:delegate_vote_end_date
				bind:vote_end_date
				bind:end_date
			/>
		{:else if calendarView === '0'}
			<div class="grid grid-cols-2 gap-6 justify-center">
				<div>
					<h2 class="mt-4">{$_('Poll start')}</h2>
					<DateInput
						format="yyyy-MM-dd HH:mm"
						closeOnSelection
						bind:value={start_date}
						min={new Date()}
						max={maxDatePickerYear}
					/>
				</div>
				{#if selected_poll !== 'Date Poll'}
					<div>
						<h2 class="mt-4">{$_('Area voting end')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={area_vote_end_date}
							min={start_date}
							max={maxDatePickerYear}
						/>
					</div>

					<div>
						<h2 class="mt-4">{$_('Proposal end')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={proposal_end_date}
							min={area_vote_end_date}
							max={maxDatePickerYear}
						/>
					</div>

					<div>
						<h2 class="mt-4">{$_('Prediction statement end')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={prediction_statement_end_date}
							min={proposal_end_date}
							max={maxDatePickerYear}
						/>
					</div>
					<div>
						<h2 class="mt-4">{$_('Prediction bet end')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={prediction_bet_end_date}
							min={prediction_statement_end_date}
							max={maxDatePickerYear}
						/>
					</div>
					<div>
						<h2 class="mt-4">{$_('Delegate Voting end date')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={delegate_vote_end_date}
							min={prediction_bet_end_date}
							max={maxDatePickerYear}
						/>
					</div>
					<div>
						<h2 class="mt-4">{$_('Voting end date')}</h2>
						<DateInput
							format="yyyy-MM-dd HH:mm"
							closeOnSelection
							bind:value={vote_end_date}
							min={delegate_vote_end_date}
							max={maxDatePickerYear}
						/>
					</div>
				{/if}
				<div>
					<h2 class="mt-4">{$_('End date')}</h2>
					<DateInput
						format="yyyy-MM-dd HH:mm"
						closeOnSelection
						bind:value={end_date}
						min={vote_end_date}
						max={maxDatePickerYear}
					/>
				</div>
			</div>
		{/if}
	</div>
	<TimelineTemplate
		area_vote_time_delta={area_vote_end_date.getTime() - start_date.getTime()}
		proposal_time_delta={proposal_end_date.getTime() - area_vote_end_date.getTime()}
		prediction_statement_time_delta={prediction_statement_end_date.getTime() -
			proposal_end_date.getTime()}
		prediction_bet_time_delta={prediction_bet_end_date.getTime() -
			prediction_statement_end_date.getTime()}
		delegate_vote_time_delta={delegate_vote_end_date.getTime() - prediction_bet_end_date.getTime()}
		vote_time_delta={vote_end_date.getTime() - delegate_vote_end_date.getTime()}
		end_time_delta={end_date.getTime() - vote_end_date.getTime()}
		poll_type={selected_poll === 'Text Poll' ? 4 : 3}
		{handleSelectTemplate}
	/>
{/if}
