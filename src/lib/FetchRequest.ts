export function fetchRequest(method: string, api: string, data: any) {
	return fetch('https://v2.flowback.org/' + api, {
		method,
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(data)
	});
}

export function getRequest(api: string, Authorization: string) {
	return fetch('https://v2.flowback.org/' + api, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			Authorization
		}
	});
}
