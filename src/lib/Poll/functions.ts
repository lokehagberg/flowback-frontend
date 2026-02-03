import { fetchRequest } from '$lib/FetchRequest';
import { _ } from 'svelte-i18n';
import type { Phase, poll } from './interface';

export const formatDate = (dateInput: string) => {
  const date = new Date(dateInput);
  return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
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
  'Start Date',
  'Area voting',
  'Proposals creation',
  'Prediction statements creation',
  'Consequence probabilities',
  'Delegate voting',
  'Voting for non-delegates',
  'Results and evaluation'
];

const dateLabelsDate = [
  'Date Voting',
  'Results'
]

export const dateLabelsDatePoll = ['Hasn\'t started yet',
  'Schedule', 'Results'];

export const getPhaseUserFriendlyName = (phase: Phase) => {
  switch (phase) {
    case 'pre_start':
      return dateLabels[0];
    case 'area_vote':
      return dateLabels[1];
    case 'proposal':
      return dateLabels[2];
    case 'prediction_statement':
      return dateLabels[3];
    case 'prediction_bet':
      return dateLabels[4];
    case 'delegate_vote':
      return dateLabels[5];
    case 'vote':
      return dateLabels[6];
    case 'prediction_vote':
      return dateLabels[7];
    case 'result':
      return dateLabels[8];
    default:
      return "";
  }
};

export const getPhaseUserFriendlyNameWithNumber = (phase: Phase, poll_type: number = 4) => {
  if (poll_type === 4)
    switch (phase) {
      case 'pre_start':
        return `0. ${dateLabels[0]}`;
      case 'area_vote':
        return `1. ${dateLabels[1]}`;
      case 'proposal':
        return `2. ${dateLabels[2]}`;
      case 'prediction_statement':
        return `3. ${dateLabels[3]}`;
      case 'prediction_bet':
        return `4. ${dateLabels[4]}`;
      case 'delegate_vote':
        return `5. ${dateLabels[5]}`;
      case 'vote':
        return `6. ${dateLabels[6]}`;
      case 'prediction_vote':
        return `7. ${dateLabels[7]}`;
      case 'result':
        return `8. ${dateLabels[8]}`;
      default:
        return "";
    }
  else if (poll_type === 3)
    switch (phase) {
      case 'area_vote':
        return `1. ${dateLabelsDate[0]}`;
      case 'prediction_vote':
        return `2. ${dateLabelsDate[1]}`;
      default:
        return "";
    }
  else return ""
};

//TODO: To prevent many API calls, use svelte stores to transfer information between files about groups
export const getGroupInfo = async (id: number | string) => {
  id = Number(id);
  const { res, json } = await fetchRequest('GET', `group/list?id=${id}`);
  return { res, json };
};


export const nextPhase = async (poll: poll, phase: Phase) => {

  if (phase === 'result' || phase === "prediction_vote") return 'prediction_vote';
  let _phase: Phase = 'area_vote';

  if (poll.poll_type === 4) {
    if (phase === 'area_vote') _phase = 'proposal';
    else if (phase === 'proposal') _phase = 'prediction_statement';
    else if (phase === 'prediction_statement') _phase = 'prediction_bet';
    else if (phase === 'prediction_bet') {
      _phase = 'delegate_vote';
      poll.status_prediction = 1;
    }
    else if (phase === 'delegate_vote') _phase = 'vote';
    else if (phase === 'vote') {
      _phase = 'prediction_vote';
      poll.status = 2;
    }
  } else if (poll.poll_type === 3) _phase = 'result';


  const { res, json } = await fetchRequest(
    'POST',
    `group/poll/${poll.id}/fast_forward`,
    {
      phase: _phase
    }
  );


  return _phase
};

export const imacFormatting = (imac: number | string) => {
  imac = Number(imac)
  return `${(imac * 100).toFixed(0)}%`
}
