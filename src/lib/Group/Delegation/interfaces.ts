export interface DelegatePool {
	delegates: Delegate[];
	id: number;
}

export interface Delegate {
	delegate_id: number;
	group_user_id: number;
	user_id: number;
}

export interface VoteHistory {
	poll_id: number;
	poll_title: string;
	vote: null;
}
