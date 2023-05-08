export interface KanbanEntry {
	assignee: { id: number; profile_image: string | null; username: string };
	created_by: { id: number; profile_image: string | null; username: string };
	description: string;
	id: number;
	origin_id: number;
	origin_type: string;
	tag: number;
	title: string;
    group_name:string
}
