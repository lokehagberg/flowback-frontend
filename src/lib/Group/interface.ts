export enum selectablePages {
	flow = 'flow',
	about = 'about',
	documents = 'documents',
	members = 'members',
	email = 'email',
	statistics = 'statistics',
	delegation = 'delegation'
}

export interface user {
	username: string;
	id: number;
	profile_image: null;
}

export interface delegate extends user {
	tags: string[];
}
