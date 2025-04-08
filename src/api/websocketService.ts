import { writable } from 'svelte/store';
import { env } from '$env/dynamic/public';

// Types
export interface User {
  id: number;
  username: string;
}

export interface Message {
  id: number;
  message: string;
  channel_id: number;
  user: User;
  created_at: string;
  updated_at: string;
  attachments_id?: number;
  parent_id?: number;
  topic_id?: number;
}

export interface WebSocketError {
  type: 'error';
  method: string;
  message: string;
  status: 'error';
}

// Stores
export const messagesStore = writable<Message[]>([]);
export const typingUsersStore = writable<Set<number>>(new Set());
export const connectionStatusStore = writable<'connected' | 'disconnected' | 'error'>('disconnected');

class WebSocketService {
  private socket: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectTimeout: number = 1000;
  private currentChannelId: number | null = null;

  constructor() {
    this.setupConnectionMonitoring();
  }

  connect(token: string) {
    if (this.socket?.readyState === WebSocket.OPEN) return;

    const wsUrl = `${env.PUBLIC_WEBSOCKET_API}/chat/ws?token=${token}`;
    this.socket = new WebSocket(wsUrl);

    this.socket.onopen = this.handleOpen.bind(this);
    this.socket.onmessage = this.handleMessage.bind(this);
    this.socket.onclose = this.handleClose.bind(this);
    this.socket.onerror = this.handleError.bind(this);
  }

  private handleOpen() {
    console.log('WebSocket connected');
    connectionStatusStore.set('connected');
    this.reconnectAttempts = 0;
  }

  private handleMessage(event: MessageEvent) {
    const data = JSON.parse(event.data);
    
    if (data.type === 'error') {
      console.error('WebSocket error:', data.message);
      return;
    }

    if (data.method === 'message_notify' && data.action === 'is_typing') {
      this.handleTypingIndicator(data.user.id);
      return;
    }

    // Handle regular messages
    if (data.type === 'message') {
      messagesStore.update(messages => {
        const messageExists = messages.some(m => m.id === data.id);
        if (!messageExists) {
          return [...messages, data];
        }
        return messages;
      });
    }
  }

  private handleClose(event: CloseEvent) {
    connectionStatusStore.set('disconnected');
    if (!event.wasClean && this.reconnectAttempts < this.maxReconnectAttempts) {
      setTimeout(() => this.reconnect(), this.reconnectTimeout);
    }
  }

  private handleError(error: Event) {
    console.error('WebSocket error:', error);
    connectionStatusStore.set('error');
  }

  private reconnect() {
    this.reconnectAttempts++;
    this.reconnectTimeout *= 2; // Exponential backoff
    const token = localStorage.getItem('token');
    if (token) {
      this.connect(token);
    }
  }

  private handleTypingIndicator(userId: number) {
    typingUsersStore.update(users => {
      const newUsers = new Set(users);
      newUsers.add(userId);
      setTimeout(() => {
        typingUsersStore.update(current => {
          const updated = new Set(current);
          updated.delete(userId);
          return updated;
        });
      }, 3000);
      return newUsers;
    });
  }

  sendMessage(channelId: number, message: string, topicId?: number, attachmentsId?: number, parentId?: number) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket is not connected');
    }

    const payload = {
      method: 'message_create',
      channel_id: channelId,
      message,
      ...(topicId && { topic_id: topicId }),
      ...(attachmentsId && { attachments_id: attachmentsId }),
      ...(parentId && { parent_id: parentId })
    };

    this.socket.send(JSON.stringify(payload));
  }

  updateMessage(messageId: number, message: string) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_update',
      message_id: messageId,
      message
    }));
  }

  deleteMessage(messageId: number) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_delete',
      message_id: messageId
    }));
  }

  sendTypingIndicator(channelId: number) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_notify',
      channel_id: channelId,
      action: 'is_typing'
    }));
  }

  joinChannel(channelId: number) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;
    
    this.currentChannelId = channelId;
    this.socket.send(JSON.stringify({
      method: 'connect_channel',
      channel_id: channelId
    }));
  }

  leaveChannel(channelId: number) {
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'disconnect_channel',
      channel_id: channelId
    }));
    this.currentChannelId = null;
  }

  private setupConnectionMonitoring() {
    setInterval(() => {
      if (this.socket?.readyState === WebSocket.CLOSED) {
        const token = localStorage.getItem('token');
        if (token) this.connect(token);
      }
    }, 5000);
  }

  disconnect() {
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
  }
}

export const websocketService = new WebSocketService(); 