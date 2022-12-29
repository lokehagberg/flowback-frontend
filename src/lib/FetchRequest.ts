export async function fetchRequest(
	method: 'GET' | 'POST',
	api: string,
	data: any = null,
	needs_authorization: boolean = true,
	needs_json: boolean = true
) {
	if (method === 'GET' && data !== null)
		console.warn(
			"Method 'GET' does not take any data, use query parameters instead. For example: /api?id=5"
		);

	let headers: any = {};

	if (needs_authorization) headers.Authorization = 'Token ' + "3627a0e3d15cddcecc6cebc88ac5bad2a7d55f9d";
	// if (needs_authorization) headers.Authorization = 'Token ' + (localStorage.getItem('token') || '');

	if (needs_json) {
		headers.Accept = 'application/json';
		headers['Content-Type'] = 'application/json';
		data = JSON.stringify(data);
	}

	let toSend: RequestInit = { method, headers };

	if (method !== 'GET') toSend.body = data;

	const res = await fetch(
		api.includes(import.meta.env.VITE_API) ? api : `${import.meta.env.VITE_API}/${api}`,
		toSend
	);

	try {
		const json = await res.json();
		return { res, json };
	} catch {
		return { res };
	}
}
