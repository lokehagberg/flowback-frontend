import { writable } from 'svelte/store';

const messageStore = writable('');

const createSocket = (userId: number) => {
	let socket: WebSocket;

	const token = localStorage.getItem('token') || '';

	const link = `${import.meta.env.VITE_WEBSOCKET_API}/chat/ws?token=${token}`;

	socket = new WebSocket(link);

	socket.onopen = (event) => {
		console.log('[open] Connection established');
	};

	socket.onmessage = (event) => {
		//If it was the same, then messages sent by oneself would return which yields duplicate messeges
		const messageId = JSON.parse(event.data).user.id;
		if (messageId !== userId) messageStore.set(event.data);
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

	return socket;
};

const sendMessage = async (socket: WebSocket) => {
	return async (message: string, target: number, target_type: 'direct' | 'group') => {
		if (socket.readyState <= 1 && message.length > 0) {
			await socket.send(JSON.stringify({ message, target, target_type }));
		}
	};
};

export default { createSocket, subscribe: messageStore.subscribe, sendMessage };
