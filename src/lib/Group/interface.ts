export type SelectablePage =
	'flow'
	| 'about'
	| 'documents'
	| 'members'
	| 'email'
	| 'statistics'
	| 'delegation'
	| 'tags';

export interface user {
	username: string;
	id: number;
	profile_image: null;
}

export interface delegate extends user {
	tags: string[];
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

export 	interface GroupDetails {
    active: boolean,
    cover_image: string,
    created_by: number,
    default_permission: number | null,
    description: string,
    direct_join: boolean,
    image: string,
    jitsi_room: string,
    name: string,
    public: boolean
}