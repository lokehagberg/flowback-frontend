import { writable } from 'svelte/store';

const messageStore = writable('');

let socket: WebSocket;

const token = localStorage.getItem('token') || '';
socket = new WebSocket(`ws://213.89.138.133:8000/chat/ws/direct?token=${token}`);

socket.onopen = (event) => {
	console.log('[open] Connection established');
};

socket.onmessage = (event) => {
	messageStore.set(event.data);
	console.log(`[message] Data received from server: ${event.data}`);
};

socket.onclose = (event) => {
	if (event.wasClean) {
		console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
	} else {
		console.warn('[close] Connection died');
	}
};

socket.onerror = (error) => {
	console.error(`[error] ${error}`);
};

const sendMessage = (message: string) => {
	// if (socket.readyState <= 1) {
	socket.send(JSON.stringify({ message, target: 2 }));
	// }
};

export default { subscribe: messageStore.subscribe, sendMessage };
