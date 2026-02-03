import { writable } from 'svelte/store';
import { type Message1, type PreviewMessage } from './interfaces';
import { env } from '$env/dynamic/public';
import { chatPartnerStore, previewStore } from './functions';
export const messageStore = writable<Message1 | null>(null);

const createSocket = (userId: number) => {
	const token = localStorage.getItem('token');
	// If logged out, don't create socket
	if (!token) return;

	const link = `${env.PUBLIC_WEBSOCKET_API}/chat/ws?token=${token}`,
		socket = new WebSocket(link);

	socket.onopen = () => {
		console.log('[open] Connection established');
	};

	socket.onmessage = (event) => {
		// If user types a message, just set it.
		const parsedMessage = JSON.parse(event.data);
		if (parsedMessage?.user?.id !== userId) {
			messageStore.set(parsedMessage);
		}

		// When user recieves a messages, update the preview store to reflect the new message.
		previewStore.update((previews) => {

			let preview = previews?.find((p: PreviewMessage) => p.channel_id === parsedMessage.channel_id);

			if (!preview) return previews

			if (chatPartnerStore.get() !== parsedMessage.channel_id)
				preview.recent_message = { ...parsedMessage, notified: false }

			else
				preview.recent_message = { ...parsedMessage, notified: true }
			return previews
		})

		// When recieving a message from the first time from someone, add it to the preview store.
		previewStore.update((previews) => {

			if (!previews) previews = [];
			if (previews.find((p) => p.channel_id === parsedMessage.channel_id)) return previews

			// If user A messages B for the first time, make it show up in B's chat field.
			const newPreview: PreviewMessage = {
				...parsedMessage,
				id: parsedMessage.channel_id,
				recent_message: {
					created_at: parsedMessage.timestamp,
					profile_image: parsedMessage.user.profile_image,
					user_id: parsedMessage.user.id,
					user: parsedMessage.user,
					channel_title: parsedMessage.channel_title,
					channel_origin_name: parsedMessage.channel_origin_name,
					message: parsedMessage.message,
					group_id: parsedMessage.channel_origin_name === 'group' ? parsedMessage.channel_id : undefined,
					target_id: parsedMessage.channel_origin_name === 'user' ? parsedMessage.channel_id : undefined,
					target_username: parsedMessage.channel_origin_name === 'user' ? parsedMessage.user.username : undefined,
					updated_at: parsedMessage.timestamp,
					notified: false
				},
			};

			return [...previews, newPreview];
		})
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
	console.log('at the place');

	if (socket.readyState !== WebSocket.OPEN || !message.trim()) return false;

	try {
		await socket.send(
			JSON.stringify({
				channel_id,
				message,
				// topic_id,
				// attachments_id,
				// parent_id,
				method: 'message_create'
			})
		);
		return true;
	} catch {
		return false;
	}
};

export default { createSocket, subscribe: messageStore.subscribe, sendMessage };