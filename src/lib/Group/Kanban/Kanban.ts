import type { WorkGroup } from "../WorkingGroups/interface";

export interface kanban {
	assignee: { id: number; profile_image: string; username: string };
	group: {
		id: number;
		image: string;
		name: string;
	};
	created_by: number;
	description: string | null;
	id: number;
	lane: number;
	work_group?: { name: string; id: number };
	title: string;
	origin_id: number;
	origin_type: 'group' | 'user';
	group_name: string;
	priority?: undefined | number | null;
	end_date?: null | string | Date;
	attachments: File[];
}

export interface KanbanEntry {
	assignee: { id: number; profile_image: string | null; username: string };
	created_by: { id: number; profile_image: string | null; username: string };
	description: string | null;
	id: number;
	origin_id: number;
	origin_type: string;
	tag: number;
	title: string;
	group_name: string
}

export interface kanbanEdited {
	entry_id: number;
	description: string | null;
	title: string;
	assignee: number | null;
	priority?: number | undefined | null;
	end_date?: Date | null
	images?: File[],
	work_group?: { name: string; id: number } | null
}