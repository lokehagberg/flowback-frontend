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
