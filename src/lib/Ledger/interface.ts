export interface Account {
	id: number;
	account_name: string;
	account_number: string;
	created_by: {
		id: number;
		username: string;
		profile_image: null | 'string';
		banner_image: null | 'string';
	};
}
export interface Transaction {
	id: string;
	account: Account;
	debit_amount: string;
	credit_amount: string;
	description: string;
	verification_number: string;
	date: string;
}

export interface Filter {
	account_ids: { id: number; checked: boolean, label:string }[];
	date_before: Date | null;
	date_after: Date | null;
	description: string | null;
}
