export function fetchRequest(data: any, api: string, method: string) {
	return fetch('https://v2.flowback.org/' + api, {
		method,
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(data)
	});
}
