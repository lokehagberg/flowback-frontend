import { fetchRequest } from '$lib/FetchRequest';
import type { Phase, poll } from './interface';

export const formatDate = (dateInput: string) => {
	const date = new Date(dateInput);
	return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

export const getPhase = (poll: poll): Phase => {
	const now = new Date();
	if (now < new Date(poll?.start_date)) return 'pre_start';
	else if (now >= new Date(poll?.start_date) && now < new Date(poll?.area_vote_end_date))
		return 'area_vote';
	else if (now >= new Date(poll?.area_vote_end_date) && now < new Date(poll?.proposal_end_date))
		return 'proposal';
	else if (
		now >= new Date(poll?.proposal_end_date) &&
		now < new Date(poll?.prediction_statement_end_date)
	)
		return 'prediction_statement';
	else if (
		now >= new Date(poll?.prediction_statement_end_date) &&
		now < new Date(poll?.prediction_bet_end_date)
	)
		return 'prediction_bet';
	else if (
		now >= new Date(poll?.prediction_bet_end_date) &&
		now < new Date(poll?.delegate_vote_end_date)
	)
		return 'delegate_vote';
	else if (now >= new Date(poll?.delegate_vote_end_date) && now < new Date(poll?.end_date))
		return 'vote';
	else if (now >= new Date(poll?.end_date) && now < new Date(poll?.vote_end_date)) return 'result';
	else return 'prediction_vote';
};

// Labels for the circles on the timeline
export const dateLabels = [
	'Area voting',
	'Proposals creation',
	'Prediction statements creation',
	'Prediction betting',
	'Delegate voting',
	'Voting for non-delegates',
	'Results and evaluation'
];

export const dateLabelsDatePoll = ['Start', 'Results'];

export const getPhaseUserFriendlyName = (phase: Phase) => {
	if (phase === 'area_vote') return dateLabels[0];
	else if (phase === 'proposal') return dateLabels[1];
	else if (phase === 'prediction_statement') return dateLabels[2];
	else if (phase === 'prediction_bet') return dateLabels[3];
	else if (phase === 'delegate_vote') return dateLabels[4];
	else if (phase === 'vote') return dateLabels[5];
	else if (phase === 'prediction_vote' || phase === 'result') return dateLabels[6];
};

//TODO: To prevent many API calls, use svelte stores to transfer information between files about groups
export const getGroupInfo = async (id: number | string) => {
	id = Number(id);
	const { res, json } = await fetchRequest('GET', `group/list?id=${id}`);
	return { res, json };
};
