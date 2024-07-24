export type template = {
	created_by_group_user?: {
		id: number;
		user: { id: number; username: string; profile_image: null|string; banner_image: null|string };
		is_admin: boolean;
		active: boolean;
		permission_id: null | number;
		permission_name: string
		group_id: number;
		group_name: string
		group_image: string
	};
	name: string
	poll_type: number;
	poll_is_dynamic: boolean;
	area_vote_time_delta: number;
	proposal_time_delta: number;
	prediction_statement_time_delta: number;
	prediction_bet_time_delta: number;
	delegate_vote_time_delta: number;
	vote_time_delta: number;
	end_time_delta: number;
};

export type pollType = 'Text Poll' | 'Date Poll' 