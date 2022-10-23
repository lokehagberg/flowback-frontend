let socket: WebSocket;

const token = localStorage.getItem('token') || '';
socket = new WebSocket(`ws://213.89.138.133:8000/chat/ws/direct?token=${token}`, token);

socket.onopen = (event) => {
	console.log('[open] Connection established');
};

socket.onmessage = (event) => {
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

export { socket };
