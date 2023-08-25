export interface Account {
	id: number;
	account_name: string;
	account_number: string;
	balance: number;
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
