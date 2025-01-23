import { writable } from 'svelte/store';
import { type Message1 } from './interfaces';
import {env} from "$env/dynamic/public";

export const messageStore = writable<Message1>();

const createSocket = (userId: number) => {
	let socket: WebSocket;

	const token = localStorage.getItem('token');

	if (token === undefined) return;

	const link = `${env.PUBLIC_WEBSOCKET_API}${
		env.PUBLIC_HAS_API === 'TRUE' ? '/api' : ''
	}/chat/ws?token=${token}`;

	socket = new WebSocket(link);

	socket.onopen = (event) => {
		console.log('[open] Connection established');
	};

	socket.onmessage = (event) => {
		//If it was the same, then messages sent by oneself would return which yields duplicate messeges
		const parsedMessage = JSON.parse(event.data);
		const messageId = parsedMessage.user.id;
		if (messageId !== userId) messageStore.set(parsedMessage);
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

const sendMessage = async (
	socket: WebSocket,
	channel_id: number,
	message: string,
	topic_id: number,
	attachments_id: number | null = null,
	parent_id: number | null = null
) => {
	if (socket.readyState <= 1 && message.length > 0) {
		const res = await socket.send(
			JSON.stringify({
				channel_id,
				message,
				// topic_id,
				// attachments_id,
				// parent_id,
				method: 'message_create'
			})
		);
		// console.log(res, "RESULTS")
	}
	return true;
};

// const sendMessage = async (socket: WebSocket) => {
// 	//Returns true or false whenever a message is sent to the socket or not.
// 	return async (message: string, target: number, target_type: 'direct' | 'group') => {
// 		if (socket.readyState <= 1 && message.length > 0) {
// 			await socket.send(JSON.stringify({ message, target, target_type }));
// 			return true;
// 		} else return false;
// 	};
// };

export default { createSocket, subscribe: messageStore.subscribe, sendMessage };
