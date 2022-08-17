export function fetchRequest(method: string, api: string, data: any, Authorization: string = localStorage.getItem("token")||"") {
	return fetch('https://v2.flowback.org/' + api, {
		method,
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			Authorization : "Token " + Authorization
		},
		body: JSON.stringify(data)
	});
}

//TODO: Make Authorization use session storage/svelte stores instead of local storage
export function getRequest(api: string, Authorization: string = localStorage.getItem("token")||"") {
	return fetch('https://v2.flowback.org/' + api, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			Authorization: "Token " + Authorization
		}
	});
}
