export interface notification {
	action: 'update' | 'CREATED';
	channel_name: 'group';
	channel_data: {
		group_id: number;
		group_image: string;
		group_name: string;
		thread_id?: number;
		thread_title?: string;
	};
	data: {
		group_id: number;
		poll_id: number;
		poll_title: string;
		group_image?: null | string;
		group_name?: string;
		work_group_id?: null | number;
		work_group_name?: null | string;
		thread_id?: null | string;
		thread_title?: null | string;
	};
	id: number;
	message: string;
	object_id: number;
	read: boolean;
	timestamp: string;
	tag:
		| 'poll'
		| 'thread'
		| 'group_user'
		| 'kanban'
		| 'schedule'
		| 'poll_comment'
		| 'thread_comment'
		| 'poll_vote_update';
}

