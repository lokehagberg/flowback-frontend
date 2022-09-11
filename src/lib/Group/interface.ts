export type SelectablePage =
	'flow'
	| 'about'
	| 'documents'
	| 'members'
	| 'email'
	| 'statistics'
	| 'delegation';

export interface user {
	username: string;
	id: number;
	profile_image: null;
}

export interface delegate extends user {
	tags: string[];
}
