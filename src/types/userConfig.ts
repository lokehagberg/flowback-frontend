export interface NotificationScheduleSettings {
	invited_to_event: boolean;
	event_date_changed: boolean;
	event_canceled: boolean;
	new_member_added: boolean;
	event_frequency_changed: boolean;
}

export interface NotificationKanbanSettings {
	task_assigned: boolean;
	task_priority_changed: boolean;
	task_status_changed: boolean;
}

export interface NotificationPostsSettings {
	new_thread_created: boolean;
	new_poll_created: boolean;
	vote_on_comment: boolean;
}

export interface PollSettings {
	area_voting: boolean;
	proposal_creation: boolean;
	prediction_statement_creation: boolean;
	prediction_betting: boolean;
	delegate_voting: boolean;
	voting: boolean;
}

export interface NotificationSettings {
	schedule: NotificationScheduleSettings;
	kanban: NotificationKanbanSettings;
	posts: NotificationPostsSettings;
}

export interface UserConfig {
	notificationSettings: NotificationSettings;
	pollSettings: PollSettings;
}
