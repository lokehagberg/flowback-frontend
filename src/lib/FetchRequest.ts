// I HAVE YOUR IP ADRESS: http://213.89.153.94:8000/

export function fetchRequest(method: string, api: string, data: any, needs_authorization: boolean = true) {
	
	let headers:HeadersInit = needs_authorization ?
	{
		Accept: 'application/json',
		'Content-Type': 'application/json',
		Authorization: "Token " + (localStorage.getItem('token') || '') 
	}:{
		Accept: 'application/json',
		'Content-Type': 'application/json',
	}

	return fetch('http://213.89.153.94:8000/' + api, {
		method,
		headers,
		body: JSON.stringify(data)
	});
}

//(localStorage.getItem('token') || '') 

//TODO: Make Authorization use session storage/svelte stores instead of local storage
export function getRequest(api: string, Authorization: string = localStorage.getItem("token")||"") {
	return fetch('http://213.89.153.94:8000/' + api, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			Authorization: "Token " + Authorization
		}
	});
}
