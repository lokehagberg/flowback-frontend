export function fetchRequest(
	method: string,
	api: string,
	data: any,
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

	console.log(headers);

	return fetch(`${import.meta.env.VITE_API}/${api}`, {
		method,
		headers,
		body: data
	});
}

//(localStorage.getItem('token') || '')

//TODO: Make Authorization use session storage/svelte stores instead of local storage
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
