export interface Permission {
	allow_vote: boolean;
	ban_members: boolean;
	create_poll: boolean;
	id: number;
	invite_user: boolean;
	kick_members: boolean;
	role_name: string;
}

export interface Permissions {
	allow_delegate: boolean;
	allow_vote: boolean;
	ban_members: boolean;
	create_kanban_task: boolean;
	create_poll: boolean;
	create_proposal: boolean;
	delete_kanban_task: boolean;
	delete_proposal: boolean;
	force_delete_comment: boolean;
	force_delete_poll: boolean;
	force_delete_proposal: boolean;
	id: number;
	invite_user: boolean;
	kick_members: boolean;
	poll_fast_forward: boolean;
	poll_quorum: boolean;
	prediction_bet_create: boolean;
	prediction_bet_delete: boolean;
	prediction_bet_update: boolean;
	prediction_statement_create: boolean;
	prediction_statement_delete: boolean;
	role_name: string;
	send_group_email: boolean;
	update_kanban_task: boolean;
	update_proposal: boolean;
}