import { writable } from 'svelte/store';

export type SelectablePage =
	| 'flow'
	| 'about'
	| 'documents'
	| 'members'
	| 'email'
	| 'statistics'
	| 'delegation'
	| 'tags'
	| 'kanban'
	| 'perms'
	| 'schedule'
	| 'threads'
	| 'working-groups'
	;

export interface User {
	username: string;
	id: number;
	profile_image: null;
	user_id: number;
}

export interface GroupUser {
	group_image: string;
	group_name: string;
	id: number;
	is_admin: boolean;
	permission_id: number | null;
	permission_name: string;
	user: { banner_image: string; id: number; profile_image: string; username: string };
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
	username: string;
	id: number;
	pool_id: number;
	profile_image: string;

	tags: Tag[];
}

export interface Group {
	active: boolean;
	chat_id: number;
	cover_image: string;
	created_by: number;
	blockchain_id: number;
	description: string;
	direct_join: boolean;
	hide_poll_users: boolean;
	id: number;
	image: string;
	joined: boolean;
	name: string;
	public: boolean;
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
	id: number;
}

export interface Tag {
	id: number;
	name: string;
	active: boolean;
	imac:number;
}

export interface groupUser extends User {
	user_id: number;
	is_delegate: boolean;
	is_admin: boolean;
	permission_id: number;
	permission_name: string;
	user: { id: number; username: string; profile_image: null | string; banner_image: null | string };
}

export type SelectablePages = 'Members' | 'Pending Invites' | 'Invite';

/*
	"userGroupInfo" is unused at the moment due to it not working. 
	TODO: Make it into a typescript class with derivable stores 
	Reference: https://javascript.plainenglish.io/writing-a-svelte-store-with-typescript-22fa1c901a4 
*/
export const userGroupInfo = writable({
	banner_image: '',
	delegate: false,
	id: 0,
	is_admin: false,
	permission_id: null,
	permission_name: '',
	profile_image: null,
	user_id: 0,
	username: ''
});

/*
	This works though
*/
export const userIsDelegateStore = writable(false);
export const userIdStore = writable(0);

export interface kanban {
	assignee: { id: number; profile_image: string; username: string };
	group: {
		id: number;
		image: string;
		name: string;
	};
	created_by: number;
	description: string;
	id: number;
	tag: number;
	title: string;
	origin_id: number;
	origin_type: 'group' | 'user';
	group_name: string;
	priority: undefined | number;
	end_date: null | string;
}

export interface Thread {
	created_by: {
		id: number;
		username: string;
		profile_image: null | string;
		banner_image: null | string;
	};
	title: string;
	id: number;
	total_comments:number;
	description:string;
	pinned:boolean;
	attachments:string[];
	user_vote:null|boolean
	score:number;

}