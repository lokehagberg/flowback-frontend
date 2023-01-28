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

//User has looked at a message, affects /preview primarily.
export const setTimeStamp = async (chatterId: number, selectedPage: 'direct' | 'group') => {
	fetchRequest('POST', `chat/${selectedPage}/${chatterId}/timestamp`, {
		timestamp: new Date()
	});
};
