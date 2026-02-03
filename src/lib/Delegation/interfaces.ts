import type { GroupUser } from '$lib/User/interfaces';
import type { DelegateMinimal } from '$lib/Group/interface';

export interface Delegate {
	tags: { id: number; tag_name: string; name: string; active: boolean }[];
	isInRelation: boolean;
	active: boolean;
	group_id: number;
	group_image: string;
	profile_image: string;
	group_name: string;
	id: number;
	pool_id: number;
	is_admin: boolean;
	permission_id: number | null;
	permission_name: string | null;
	user: {
		banner_image: string;
		id: number;
		profile_image: string;
		username: string;
	};
}

export interface VoteHistory {
	poll: {

		id: number;
		created_by: {
			id: number;
			is_admin: boolean;
			active: boolean;
			// add other fields here if known
			[key: string]: any;
		};
		group_id: number;
		group_name: string;
		group_image: string | null;
		tag_id: number;
		tag_name: string;
		attachments: any[] | null;
		hide_poll_users: boolean;
		title: string;
		description: string;
		poll_type: number;
		allow_fast_forward: boolean;
		public: boolean;
		start_date: string; // ISO 8601 date string
		proposal_end_date: string;
		prediction_statement_end_date: string;
		area_vote_end_date: string;
		prediction_bet_end_date: string;
		delegate_vote_end_date: string;
		vote_end_date: string;
		end_date: string;
		status: number;
		result: boolean;
		participants: number;
		pinned: boolean;
		dynamic: boolean;
		interval_mean_absolute_correctness: number | null;
		quorum: number | null;
	}

	vote: [
		{
			proposal_id: number;
			proposal_title: string;
			proposal_description?: string;
			proposal_created_by_id: number;
			proposal_created_by_name: string;
			score?: number;
			raw_score?: number;
		}
	];
}

export interface DelegatePool {
	blockchain_id: null | number;
	delegate_pool_id: number;
	delegates: {
		delegate_id: number;
		group_user_id: number;
		user_id: number;
		group_user: GroupUser;
	}[];
	id: number;
	tags: { id: number; name: string; tag_name?: string; active?: boolean }[];
}

export interface DelegateRelation {
	blockchain_id?: null | number;
	delegate_pool_id: number;
	delegates: DelegateMinimal[];
	id: number;
	tags: { name: string; id: number; active: boolean }[];
}
