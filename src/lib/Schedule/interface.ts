export interface scheduledEvent {
	created_by: number;
	description?: string;
	end_date: string;
	event_id: number;
	poll?: number;
	score?: number | null;
	start_date: string;
	title: string;
	group_id?: number;
	work_group?:
	{
		id:number;
		name:string;
	};
	schedule_origin_name: 'user' | 'group';
	meeting_link?: string;
}


export interface WorkGropuSchdeuledEventCreate{
	title: string;              
	description?: string;
	start_date: string;
	end_date?: string;
	group_id: number;
	work_group_id?: number;
	assignee_ids?: number[];
	meeting_link?: string;
}
