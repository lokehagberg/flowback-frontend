import { goto } from "$app/navigation";

//This function is a bit cursed due to problems with error codes from the backend
export const statusMessageFormatter = (res: any, json: any, successMessage: string = 'Success') => {
	if (res.ok) {
		return { message: successMessage, success: true };
	} else if (res.status - 500 >= 0) {
		return { message: 'Server Error', success: false };
	} else if (json?.detail) {
		if (
			json.detail === 'Invalid token.' ||
			json.detail === 'Invalid token header. No credentials provided.'
		) {
			//Invalid!
		}
		const messages = json.detail;
		if (messages[0] && messages[0].length > 1) return { message: messages[0], success: false };
		else {
			const errorMessage = json.detail[Object.keys(json.detail)[0]][0];
			if (errorMessage) return { message: errorMessage, success: false };
			else return { message: 'Something went wrong', success: false };
		}
	} else {
		return { message: 'Something went wrong', success: false };
	}
};
