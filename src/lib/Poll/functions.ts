import type { Phase, poll } from './interface';

export const formatDate = (dateInput: string) => {
	const date = new Date(dateInput);
	return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

export const getPhase = (poll: poll): Phase => {
	const now = new Date();
	if (now < new Date(poll?.start_date)) return 'pre-start';
	else if (now >= new Date(poll?.start_date) && now < new Date(poll?.area_vote_end_date))
		return 'area-vote';
	else if (now >= new Date(poll?.area_vote_end_date) && now < new Date(poll?.proposal_end_date))
		return 'proposals';
	else if (
		now >= new Date(poll?.proposal_end_date) &&
		now < new Date(poll?.prediction_statement_end_date)
	)
		return 'prediction-statement';
	else if (
		now >= new Date(poll?.prediction_statement_end_date) &&
		now < new Date(poll?.prediction_bet_end_date)
	)
		return 'prediction-betting';
	else if (
		now >= new Date(poll?.prediction_bet_end_date) &&
		now < new Date(poll?.delegate_vote_end_date)
	)
		return 'delegate-voting';
	else if (now >= new Date(poll?.delegate_vote_end_date) && now < new Date(poll?.end_date))
		return 'voting';
	else if (now >= new Date(poll?.end_date) && now < new Date(poll?.vote_end_date)) return 'results';
	else return 'prediction-voting';
};

export const dateLabels = [
	'Pre Start',
	'Tag voting',
	'Proposals creation',
	'Prediction statements creation',
	'Prediction betting',
	'Delegate voting',
	'Voting for non-delegates',
	'Results and evaluation'
];

export const getPhaseUserFriendlyName = (phase: Phase) => {
	if (phase === 'pre-start') return dateLabels[0];
	else if (phase === 'area-vote') return dateLabels[1];
	else if (phase === 'proposals') return dateLabels[2];
	else if (phase === 'prediction-statement') return dateLabels[3];
	else if (phase === 'prediction-betting') return dateLabels[4];
	else if (phase === 'delegate-voting') return dateLabels[5];
	else if (phase === 'voting') return dateLabels[6];
	else if (phase === 'prediction-voting' || phase === 'results') return dateLabels[7];
};
