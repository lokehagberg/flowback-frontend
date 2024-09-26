export interface WorkGroup {
	name: string;
	members: number | null;
	direct_join: boolean;
	id: number;
}

export interface WorkGroupUser {
	id: number;
	work_group_id: number;
	work_group_name: string;
	group_user: {
		id: number;
		user: {
			id: number;
			username: string;
			profile_image: string;
			banner_image: string;
		};
		is_admin: boolean;
		active: boolean;
		permission_id: number;
		permission_name: string;
		group_id: number;
		group_name: string;
		group_image: string;
	};
	is_moderator: boolean;
}
