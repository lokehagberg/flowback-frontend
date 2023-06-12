export interface DelegatePool {
	delegates: Delegate[];
	id: number;
}

export interface Delegate {
	delegate_id: number;
	group_user_id: number;
	user_id: number;
}
