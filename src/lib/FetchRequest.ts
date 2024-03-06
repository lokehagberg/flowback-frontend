import { browser } from '$app/environment';
import {PUBLIC_API_URL, PUBLIC_HAS_API} from "$env/static/public";

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

		// Redirect if no token
		if (token === null) location.href = '/login';
		else headers.Authorization = 'Token ' + (localStorage.getItem('token') || '');
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
		api.includes(PUBLIC_API_URL)
			? `${api}`
			: `${PUBLIC_API_URL}${
				PUBLIC_HAS_API === 'TRUE' ? '/api/' : '/'
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
