import { fetchRequest } from '$lib/FetchRequest';

export interface Message {
	message: string;
	user: {
		id: number;
		username: string;
		profile_image: string | null;
	};
	username?: string;
	created_at?: string;
}

export interface Message1 {
	active: boolean;
	attachments: null | File;
	channel_id: number;
	channel_origin_name: 'group' | 'user';
	created_at: String;
	id: number;
	message: string;
	parent: number;
	topic_id: number;
	type: 'message';
	updated_at: String;
	user: { id: number; username: string; profile_image: string; banner_image: string };
}

//Taken from the preview API
export interface PreviewMessage {
	created_at: string;
	message: string;
	profile_image: string;
	timestamp: string;
	user_id: number;
	updated_at?:string;
	id: number;
	notified: boolean;
	//For group/preview
	group_id?: number;
	channel_id?: number;
	//For direct/preview
	user: {
		id: number;
		username: string;
		profile_image: string | null;
		banner_image: string | null;
	};
	target_id?: number;
	target_username?: string;
}

export interface Direct {
	id: number;
	profile_image: string | null;
	username: string;
}

//User has looked at a message, affects /preview primarily.
export const setTimeStamp = async (chatterId: number, selectedPage: 'direct' | 'group') => {
	fetchRequest('POST', `chat/${selectedPage}/${chatterId}/timestamp`, {
		timestamp: new Date()
	});
};
