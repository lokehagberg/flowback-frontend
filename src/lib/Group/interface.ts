import { writable } from 'svelte/store';

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
	pool_id: number;
	profile_image: File;
	username: string;
	tags: { id: number; tag_name: string }[];
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
	id: number;
}

export interface Tag {
	id: number;
	tag_name: string;
	active: boolean;
}

export type SelectablePages = 'Members' | 'Pending Invites' | 'Invite';


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


export const userIsDelegateStore = writable(false)