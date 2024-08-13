import type { GroupUser } from '$lib/User/interfaces';

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
	poll_id: number;
	poll_title: string;
	vote: null;
}

export interface DelegatePool {
	blockchain_id: null | number;
	delegate_pool_id: number;
	delegates: { delegate_id: number; group_user_id: number; user_id: number }[];
	id: number;
	tags: { id: number; name: string, tag_name?:string; active?:boolean }[];
}
