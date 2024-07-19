import { browser } from '$app/environment';
import { goto } from '$app/navigation';

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

	if (!browser) return { res: { ok: false }, json: {} };

	if (needs_authorization) {
		const token = localStorage.getItem('token');

		if (token !== null) headers.Authorization = 'Token ' + (localStorage.getItem('token') || '');
		else goto('/login');
	}

	if (needs_json) {
		headers.Accept = 'application/json';
		headers['Content-Type'] = 'application/json';
		data = JSON.stringify(data);
	}

	let toSend: RequestInit = { method, headers };

	if (method !== 'GET') toSend.body = data;

	const res = await fetch(
		//TODO: Make /api/ not hardcodd
		api.includes(import.meta.env.VITE_API)
			? `${api}`
			: `${import.meta.env.VITE_API}${
					import.meta.env.VITE_HAS_API === 'TRUE' ? '/api/' : '/'
			  }${api}`,
		toSend
	);

	try {
		const json = await res.json();
		return { res, json };
	} catch {
		return { res };
	}
}
