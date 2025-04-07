import { writable } from 'svelte/store';
import { env } from '$env/dynamic/public';
import { browser } from '$app/environment';
import type { Message as APIMessage, User } from './chat';
import { chat } from './chat';

// Types
export interface WebSocketMessage {
  type: string;
  method?: string;
  action?: string;
  message?: string;
  user?: User;
  channel_id?: number;
  channel_title?: string;
  channel_origin_name?: string;
  id?: number;
  created_at?: string;
  updated_at?: string;
  attachments?: any[];
  active?: boolean;
  parent_id?: number;
  parent?: APIMessage;
}

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

export type ConnectionStatus = 'connecting' | 'connected' | 'disconnected' | 'error';

// Stores
export const messagesStore = writable<APIMessage[]>([]);
export const typingUsersStore = writable<Set<number>>(new Set());
export const connectionStatusStore = writable<ConnectionStatus>('disconnected');
export const chatParticipantsStore = writable<Map<number, ChatParticipant>>(new Map());
export const loadingMessagesStore = writable<boolean>(false);

class WebSocketService {
  private socket: WebSocket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectTimeout: number = 1000;
  private currentChannelId: number | null = null;
  private monitoringInterval: ReturnType<typeof setInterval> | null = null;

  constructor() {
    if (browser) {
      this.setupConnectionMonitoring();
    }
  }

  connect(token: string) {
    if (!browser) return;
    if (this.socket?.readyState === WebSocket.OPEN) return;

    connectionStatusStore.set('connecting');
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
    
    // Rejoin channel if there was one
    if (this.currentChannelId) {
      this.joinChannel(this.currentChannelId);
    }
  }

  private async loadChannelHistory(channelId: number) {
    try {
      loadingMessagesStore.set(true);
      const response = await chat.getMessages(channelId, { limit: 50, order_by: 'created_at_desc' });
      if (response.results) {
        // Reverse to show oldest first
        const messages = response.results.reverse();
        messagesStore.set(messages);
      }
    } catch (error) {
      console.error('Error loading channel history:', error);
    } finally {
      loadingMessagesStore.set(false);
    }
  }

  private handleMessage(event: MessageEvent) {
    try {
      const data: WebSocketMessage = JSON.parse(event.data);
      
      if (data.type === 'error') {
        console.error('WebSocket error:', data.message);
        return;
      }

      if (data.method === 'message_notify' && data.action === 'is_typing' && data.user) {
        this.handleTypingIndicator(data.user.id, data.user.username);
        return;
      }

      // Handle regular messages
      if ((data.type === 'message' || (!data.type && data.message)) && data.user) {
        const message: APIMessage = {
          id: data.id || 0,
          user: data.user,
          created_at: data.created_at || new Date().toISOString(),
          updated_at: data.updated_at || new Date().toISOString(),
          channel_id: data.channel_id || this.currentChannelId || 0,
          channel_origin_name: data.channel_origin_name || '',
          channel_title: data.channel_title || '',
          type: data.type || 'message',
          message: data.message || '',
          attachments: data.attachments || null,
          parent_id: data.parent_id,
          parent: data.parent,
          active: data.active ?? true
        };

        // Update participants
        chatParticipantsStore.update(participants => {
          const updated = new Map(participants);
          updated.set(message.user.id, {
            id: message.user.id,
            username: message.user.username,
            isTyping: false
          });
          return updated;
        });

        // Update messages
        messagesStore.update(messages => {
          const messageExists = messages.some(m => m.id === message.id);
          if (!messageExists) {
            return [...messages, message];
          }
          return messages.map(m => m.id === message.id ? message : m);
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
    if (!browser || !message.trim()) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      throw new Error('WebSocket is not connected');
    }

    const payload = {
      method: 'message_create',
      channel_id: channelId,
      message: message.trim(),
      ...(topicId && { topic_id: topicId }),
      ...(attachmentsId && { attachments_id: attachmentsId }),
      ...(parentId && { parent_id: parentId })
    };

    this.socket.send(JSON.stringify(payload));
  }

  updateMessage(messageId: number, message: string) {
    if (!browser || !message.trim()) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;

    this.socket.send(JSON.stringify({
      method: 'message_update',
      message_id: messageId,
      message: message.trim()
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

  async joinChannel(channelId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) return;
    
    this.currentChannelId = channelId;
    
    // Load message history first
    await this.loadChannelHistory(channelId);
    
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
    
    // Clear messages and current channel when leaving
    messagesStore.set([]);
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
    if (this.currentChannelId) {
      this.leaveChannel(this.currentChannelId);
    }
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
    messagesStore.set([]);
    typingUsersStore.set(new Set());
    chatParticipantsStore.set(new Map());
    connectionStatusStore.set('disconnected');
  }
}

export const websocketService = new WebSocketService(); 