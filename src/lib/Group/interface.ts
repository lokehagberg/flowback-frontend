export type SelectablePage =
	| 'flow'
	| 'about'
	| 'documents'
	| 'members'
	| 'email'
	| 'statistics'
	| 'delegation'
	| 'tags';

export interface User {
	username: string;
	id: number;
	profile_image: null;
}

export interface DelegatePools {
	data: [
		{
			id: number;
			delegates: {
				delegate_id: number;
				group_user_id: number;
				user_id: number;
			};
		}
	];
}

export interface Delegate {
	id: number;
	pool_id:number;
	profile_image: File;
	username: string;
	tags: {id:number, tag_name:string}[];
}

export interface Group {
	active: boolean;
	cover_image: string;
	created_by: number;
	description: string;
	direct_join: boolean;
	id: number;
	image: string;
	joined: boolean;
	name: string;
}

export interface GroupDetails {
	active: boolean;
	cover_image: string;
	created_by: number;
	default_permission: number | null;
	description: string;
	direct_join: boolean;
	image: string;
	jitsi_room: string;
	name: string;
	public: boolean;
}

export type SelectablePages = 'Members' | 'Pending Invites' | 'Invite';
