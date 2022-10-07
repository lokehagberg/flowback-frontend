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
