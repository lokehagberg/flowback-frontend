export interface proposal {
	title: string;
	description: string;
	id: number;
}

export interface poll {
	created_by: number;
	description: string;
	dynamic: boolean;
	end_date: string;
	finished: boolean;
	id: number;
	participants: number;
	poll_type: number;
	result: boolean;
	start_date: string;
	tag: number;
	tag_name: string;
	title: string;
}

export interface votings {
	author: number;
	author_delegate: number | null;
	priority: number;
	proposal: number;
	score: number;
}

export interface Filter {
	finished: boolean;
	public: boolean;
	search: string;
}