export interface Account {
	id: number;
	account_name: string;
	account_number: string;
	created_by : {
		id:number,
		username : string,
		profile_image: null | 'string',
		banner_image: null | 'string'
	}
}
export interface Transaction {
	id: number;
	account: Account;
	debit_amount: number;
	credit_amount: number;
	description: string;
	verification_number: string;
	date: string;
}
