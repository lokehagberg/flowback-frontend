export async function fetchRequest(
	method: 'GET' | 'POST' | 'EDIT' | 'DELETE' | 'PUT',
	api: string,
	data: any = {},
	needs_authorization: boolean = true,
	needs_json: boolean = true
) {
	console.log(data);
	let headers: any = {};

	if (needs_authorization) headers.Authorization = 'Token ' + (localStorage.getItem('token') || '');

	if (needs_json) {
		headers.Accept = 'application/json';
		headers['Content-Type'] = 'application/json';
		data = JSON.stringify(data);
	}

	let toSend:RequestInit = {method, headers}

	if (method !== "GET") toSend.body = data

	return await fetch(`${import.meta.env.VITE_API}/${api}`, toSend);
}

/**
 * @deprecated The method should not be used
 */
export function getRequest(
	api: string,
	Authorization: string = localStorage.getItem('token') || ''
) {
	return fetch(`${import.meta.env.VITE_API}/${api}`, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			Authorization: 'Token ' + Authorization
		}
	});
}
