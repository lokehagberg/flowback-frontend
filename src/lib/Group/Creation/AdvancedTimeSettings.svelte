<script lang="ts">
	import { DateInput } from 'date-picker-svelte';
	import Button from '$lib/Generic/Button.svelte';
	import TextInput from '$lib/Generic/TextInput.svelte';
	import { page } from '$app/stores';
	import { fetchRequest } from '$lib/FetchRequest';
	import TextArea from '$lib/Generic/TextArea.svelte';
	import type { Tag as TagType } from '$lib/Group/interface';
	import StatusMessage from '$lib/Generic/StatusMessage.svelte';

	import { _ } from 'svelte-i18n';
	import type { StatusMessageInfo } from '$lib/Generic/GenericFunctions';
	//@ts-ignore
	//@ts-ignore
	import Fa from 'svelte-fa/src/fa.svelte';
	import { faArrowUp } from '@fortawesome/free-solid-svg-icons/faArrowUp';
	import { faArrowDown } from '@fortawesome/free-solid-svg-icons/faArrowDown';
	import { faX } from '@fortawesome/free-solid-svg-icons/faX';
	import { faCheck } from '@fortawesome/free-solid-svg-icons/faCheck';
	import { faWallet } from '@fortawesome/free-solid-svg-icons/faWallet';
	import { faSliders } from '@fortawesome/free-solid-svg-icons/faSliders';
	import { faCalendarAlt } from '@fortawesome/free-solid-svg-icons/faCalendarAlt';
	import { faAlignLeft } from '@fortawesome/free-solid-svg-icons/faAlignLeft';
	import { faHourglass } from '@fortawesome/free-solid-svg-icons/faHourglass';
	import { faClockRotateLeft } from '@fortawesome/free-solid-svg-icons/faClockRotateLeft';
	import Loader from '$lib/Generic/Loader.svelte';
	import RadioButtons from '$lib/Generic/RadioButtons.svelte';
	import { statusMessageFormatter } from '$lib/Generic/StatusMessage';
	import { maxDatePickerYear } from '$lib/Generic/DateFormatter';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { createPoll as createPollBlockchain } from '$lib/Blockchain/javascript/pollsBlockchain';
	import FileUploads from '$lib/Generic/FileUploads.svelte';
	import TimelineTemplate from './TimelineTemplate.svelte';
	import type { pollType, template } from './interface';

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

	let daysBetweenPhases = 1;

	const handleSelectTemplate = (template: template) => {
		const now = new Date().getTime();
		start_date = new Date();

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

	$: (daysBetweenPhases || !daysBetweenPhases) && changeDaysBetweenPhases();

	const changeDaysBetweenPhases = () => {
		const now = new Date();
		start_date = new Date();

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
