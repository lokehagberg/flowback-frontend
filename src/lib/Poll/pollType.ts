export const POLL_TYPE = {
	SCHEDULE: 'schedule',
	SCORE: 'score',
	V2_SCORE: 'v2_score'
} as const;

export type PollType = (typeof POLL_TYPE)[keyof typeof POLL_TYPE];

export const isSchedulePoll = (pollType: PollType | null | undefined): pollType is typeof POLL_TYPE.SCHEDULE =>
	pollType === POLL_TYPE.SCHEDULE;

export const isV2ScorePoll = (pollType: PollType | null | undefined): pollType is typeof POLL_TYPE.V2_SCORE =>
	pollType === POLL_TYPE.V2_SCORE;

export const isScorePoll = (
	pollType: PollType | null | undefined
): pollType is typeof POLL_TYPE.SCORE | typeof POLL_TYPE.V2_SCORE =>
	pollType === POLL_TYPE.SCORE || pollType === POLL_TYPE.V2_SCORE;

