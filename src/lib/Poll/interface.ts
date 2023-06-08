export interface proposal {
	title: string;
	description: string;
	id: number;
	created_by: number;
	poll: number;
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
	group_id: number;
	proposal_end_date: string;
	vote_start_date: string;
	prediction_end_date: string;
	delegate_vote_end_date: string;
	group_name?: string;
	group_image?: string;
	joined: boolean;
	group_joined: boolean;
	total_comments: number;
	pinned:boolean;
}

export interface votings {
	author: number;
	author_delegate: number | null;
	priority: number;
	proposal: number;
	score: number;
}

export interface Filter {
	public: boolean;
	finishedSelection: 'all' | 'unfinished' | 'finished';
	search: string;
	order_by: 'start_date_asc' | 'start_date_desc';
	tag:number | null
}

export type Phase = 'pre-start' | 'proposals' | 'prediction' | 'delegate-voting' | 'voting' | 'end';

export interface Comment {
	author_id: number;
	author_name: string;
	author_thumbnail: string;
	parent_id?: number;
	reply_depth: number;
	message: string;
	score: number;
	being_edited: boolean;
	being_replied: boolean;
	being_edited_message?: string;
	id: number;
	//False if comment has been deleted
	active: boolean;
	edited: boolean;
}

export interface CommentEdited {}
