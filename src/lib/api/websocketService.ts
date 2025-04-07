import { writable } from 'svelte/store';
import { env } from '$env/dynamic/public';
import { browser } from '$app/environment';
import type { Message as APIMessage } from './chat';

// Types
export type { Message } from './chat';

export interface ChatParticipant {
  id: number;
  username: string;
  isTyping: boolean;
}

export interface WebSocketError {
  type: 'error';
  method: string;
  message: string;
  status: 'error';
}

// Stores
export const messagesStore = writable<APIMessage[]>([]);
export const typingUsersStore = writable<Set<number>>(new Set());
export const connectionStatusStore = writable<'connected' | 'disconnected' | 'error'>('disconnected');
export const chatParticipantsStore = writable<Map<number, ChatParticipant>>(new Map());

class WebSocketService {
  private socket: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectTimeout: number = 1000;
  private currentChannelId: number | null = null;
  private monitoringInterval: NodeJS.Timer | null = null;

  constructor() {
    if (browser) {
      this.setupConnectionMonitoring();
    }
  }

  connect(token: string) {
    if (!browser) return;
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
    try {
      const data = JSON.parse(event.data);
      
      if (data.type === 'error') {
        console.error('WebSocket error:', data.message);
        return;
      }

      if (data.method === 'message_notify' && data.action === 'is_typing') {
        this.handleTypingIndicator(data.user.id, data.user.username);
        return;
      }

      // Handle regular messages
      if (data.type === 'message' || (!data.type && data.message)) {
        const message: APIMessage = {
          ...data,
          type: data.type || 'message',
          active: data.active ?? true,
          attachments: data.attachments || null
        };

        // Update participants
        if (message.user) {
          chatParticipantsStore.update(participants => {
            const updated = new Map(participants);
            updated.set(message.user.id, {
              id: message.user.id,
              username: message.user.username,
              isTyping: false
            });
            return updated;
          });
        }

        messagesStore.update(messages => {
          const messageExists = messages.some(m => m.id === message.id);
          if (!messageExists) {
            return [...messages, message];
          }
          return messages;
        });
      }
    } catch (error) {
      console.error('Error handling WebSocket message:', error);
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
    if (!browser) return;
    this.reconnectAttempts++;
    this.reconnectTimeout *= 2; // Exponential backoff
    const token = localStorage.getItem('token');
    if (token) {
      this.connect(token);
    }
  }

  private handleTypingIndicator(userId: number, username: string) {
    // Update typing users
    typingUsersStore.update(users => {
      const newUsers = new Set(users);
      newUsers.add(userId);
      return newUsers;
    });

    // Update participant typing status
    chatParticipantsStore.update(participants => {
      const updated = new Map(participants);
      const participant = updated.get(userId) || { id: userId, username, isTyping: false };
      updated.set(userId, { ...participant, isTyping: true });
      
      // Reset typing status after timeout
      setTimeout(() => {
        chatParticipantsStore.update(current => {
          const map = new Map(current);
          const user = map.get(userId);
          if (user) {
            map.set(userId, { ...user, isTyping: false });
          }
          return map;
        });

        typingUsersStore.update(current => {
          const updated = new Set(current);
          updated.delete(userId);
          return updated;
        });
      }, 3000);

      return updated;
    });
  }

  sendMessage(channelId: number, message: string, topicId?: number, attachmentsId?: number, parentId?: number) {
    if (!browser) return;
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
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_update',
      message_id: messageId,
      message
    }));
  }

  deleteMessage(messageId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_delete',
      message_id: messageId
    }));
  }

  sendTypingIndicator(channelId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_notify',
      channel_id: channelId,
      action: 'is_typing'
    }));
  }

  joinChannel(channelId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;
    
    this.currentChannelId = channelId;
    this.socket.send(JSON.stringify({
      method: 'connect_channel',
      channel_id: channelId
    }));
  }

  leaveChannel(channelId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'disconnect_channel',
      channel_id: channelId
    }));
    this.currentChannelId = null;
  }

  private setupConnectionMonitoring() {
    if (!browser) return;
    
    this.monitoringInterval = setInterval(() => {
      if (this.socket?.readyState === WebSocket.CLOSED) {
        const token = localStorage.getItem('token');
        if (token) this.connect(token);
      }
    }, 5000);
  }

  disconnect() {
    if (!browser) return;
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
  }
}

export const websocketService = new WebSocketService(); 