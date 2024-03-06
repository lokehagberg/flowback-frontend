import type { Phase, poll } from "./interface";

export const formatDate = (dateInput: string) => {
	const date = new Date(dateInput);
	return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

export const getPhase = (poll:poll): Phase => {
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
	else if (now >= new Date(poll?.end_date) && now < new Date(poll?.vote_end_date))
		return 'results';
	else return 'prediction-voting';
};