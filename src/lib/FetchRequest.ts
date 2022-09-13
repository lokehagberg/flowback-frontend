export function fetchRequest(
	method: string,
	api: string,
	data: any,
	needs_authorization: boolean = true
) {
	console.log(data);
	console.log(JSON.stringify(data));

	let headers: HeadersInit = needs_authorization
		? {
				Accept: 'application/json',
				'Content-Type': 'application/json',
				Authorization: 'Token ' + (localStorage.getItem('token') || '')
		  }
		: {
				Accept: 'application/json',
				'Content-Type': 'application/json'
		  };

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
