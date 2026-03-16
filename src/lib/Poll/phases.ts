import type { Phase, poll } from './interface';

export interface PollPhaseConfig {
  key: Phase;
  label: string;
  endDateField: keyof poll | null;
  showInTimeline: boolean;
}

export const TEXT_POLL_PHASE_CONFIG: PollPhaseConfig[] = [
  { key: 'pre_start', label: 'Start Date', endDateField: 'start_date', showInTimeline: true },
  { key: 'proposal', label: 'Proposals creation', endDateField: 'proposal_end_date', showInTimeline: true },
  { key: 'prediction_bet', label: 'Predictions', endDateField: 'prediction_bet_end_date', showInTimeline: true },
  { key: 'delegate_vote', label: 'Delegate voting', endDateField: 'delegate_vote_end_date', showInTimeline: true },
  { key: 'vote', label: 'Voting for non-delegates', endDateField: 'end_date', showInTimeline: true },
  { key: 'prediction_vote', label: 'Results and evaluation', endDateField: null, showInTimeline: false },
];
