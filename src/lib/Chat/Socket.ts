import { writable } from 'svelte/store';

const messageStore = writable('');

//Maybe TODO: Make this class based, maybe a "SocketManager" class.
const createSocket = (id: number, type: 'Direkt' | 'Grupper') => {
	let socket: WebSocket;

	const token = localStorage.getItem('token') || '';

	const link =
		type === 'Grupper'
			? `${import.meta.env.VITE_WEBSOCKET_API}/chat/ws/group/${id}?token=${token}`
			: `${import.meta.env.VITE_WEBSOCKET_API}/chat/ws/direct?token=${token}`;

	socket = new WebSocket(link);

	socket.onopen = (event) => {
		console.log('[open] Connection established');
	};

	socket.onmessage = (event) => {
		messageStore.set(event.data);
		console.log(`[message] Data received from server: ${event.data}`);
	};

	socket.onclose = (event) => {
		messageStore.set('');
		if (event.wasClean) {
			console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
		} else {
			console.warn('[close] Connection died');
		}
	};

	socket.onerror = (error) => {
		console.error(`[error] ${error}`);
	};

	return socket;
};

const sendMessage = (target: number, socket: WebSocket) => {
	return (message: string) => {
		if (socket.readyState <= 1) {
			socket.send(JSON.stringify({ message, target }));
		}
	};
};

export default { createSocket, subscribe: messageStore.subscribe, sendMessage };
