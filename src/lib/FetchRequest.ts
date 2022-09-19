export async function fetchRequest(
	method: 'GET' | 'POST',
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

	const res = await fetch(`${import.meta.env.VITE_API}/${api}`, toSend);
	const json = await res.json()

	return {res, json}
}