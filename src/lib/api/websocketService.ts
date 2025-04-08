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
  status?: string;
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
  private isVisible = false;
  private currentToken: string | null = null;
  private isReconnecting = false;

  constructor() {
    if (browser) {
      this.setupConnectionMonitoring();
    }
  }

  isConnected(): boolean {
    return this.socket !== null && this.socket.readyState === WebSocket.OPEN;
  }

  setVisibility(visible: boolean) {
    this.isVisible = visible;
    if (!visible) {
      // Instead of cleaning up the connection, just leave the current channel
      if (this.currentChannelId) {
        this.leaveChannel(this.currentChannelId);
      }
    } else if (this.currentToken && !this.isConnected()) {
      // Only reconnect if we have a token and aren't already connected
      this.connect(this.currentToken);
    }
  }

  connect(token: string) {
    if (!browser || !this.isVisible || this.isReconnecting) return;
    if (this.isConnected() && this.currentToken === token) return;

    // Clean up existing connection if any
    this.cleanupConnection();

    this.currentToken = token;
    connectionStatusStore.set('connecting');
    const wsUrl = `${env.PUBLIC_WEBSOCKET_API}/chat/ws?token=${token}`;
    
    try {
      this.socket = new WebSocket(wsUrl);
      this.socket.onopen = this.handleOpen.bind(this);
      this.socket.onmessage = this.handleMessage.bind(this);
      this.socket.onclose = this.handleClose.bind(this);
      this.socket.onerror = this.handleError.bind(this);
    } catch (error) {
      console.error('Error creating WebSocket:', error);
      this.handleConnectionFailure();
    }
  }

  private handleOpen() {
    console.log('WebSocket connected');
    connectionStatusStore.set('connected');
    this.reconnectAttempts = 0;
    this.reconnectTimeout = 1000;
    this.isReconnecting = false;
  }

  private async loadChannelHistory(channelId: number) {
    try {
      loadingMessagesStore.set(true);
      const response = await chat.getMessages(channelId, { 
        limit: 50, 
        order_by: 'created_at_asc'  // Load messages in ascending order
      });
      if (response.results) {
        messagesStore.set(response.results);
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
      
      // Handle server error messages
      if (data.type === 'error' || data.status === 'error') {
        console.error('Server error:', data.message);
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

        // Update messages while preserving history
        messagesStore.update(messages => {
          // Check if message already exists
          const messageExists = messages.some(m => m.id === message.id);
          if (!messageExists) {
            // Add new message while preserving history
            return [...messages, message].sort((a, b) => 
              new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
            );
          }
          // Update existing message while preserving order
          return messages.map(m => m.id === message.id ? message : m);
        });
      }
    } catch (error) {
      console.error('Error handling WebSocket message:', error);
    }
  }

  private handleClose(event: CloseEvent) {
    console.log('WebSocket closed:', event.code, event.reason);
    
    // Don't attempt to reconnect if the closure was clean or intentional
    if (event.wasClean || !this.isVisible || !this.currentToken) {
      connectionStatusStore.set('disconnected');
      return;
    }

    this.handleConnectionFailure();
  }

  private handleError(error: Event) {
    console.error('WebSocket error:', error);
    // Don't set error status or attempt reconnect if we're already trying to reconnect
    if (!this.isReconnecting) {
      this.handleConnectionFailure();
    }
  }

  private handleConnectionFailure() {
    // Only update status if not already reconnecting
    if (!this.isReconnecting) {
      connectionStatusStore.set('error');
    }
    
    if (this.isVisible && this.reconnectAttempts < this.maxReconnectAttempts && !this.isReconnecting) {
      this.isReconnecting = true;
      setTimeout(() => this.reconnect(), this.reconnectTimeout);
    } else if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      connectionStatusStore.set('disconnected');
      this.cleanupConnection();
    }
  }

  private reconnect() {
    if (!browser || !this.isVisible || !this.currentToken) {
      this.isReconnecting = false;
      return;
    }
    
    this.reconnectAttempts++;
    this.reconnectTimeout = Math.min(this.reconnectTimeout * 2, 30000);
    
    this.connect(this.currentToken);
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

  async joinChannel(channelId: number) {
    if (!browser) return;

    // If we're not connected, wait for connection
    if (!this.isConnected()) {
      console.log('Waiting for WebSocket connection...');
      await new Promise<void>((resolve) => {
        const unsubscribe = connectionStatusStore.subscribe((status) => {
          if (status === 'connected') {
            unsubscribe();
            resolve();
          }
        });
      });
    }
    
    // If we're already in this channel, no need to rejoin
    if (this.currentChannelId === channelId) {
      return;
    }
    
    // If we're in a different channel, leave it first
    if (this.currentChannelId && this.currentChannelId !== channelId) {
      this.leaveChannel(this.currentChannelId);
    }
    
    this.currentChannelId = channelId;
    
    try {
      // Load message history
      await this.loadChannelHistory(channelId);
      
      // Join the websocket channel
      this.socket?.send(JSON.stringify({
        method: 'connect_channel',
        channel_id: channelId
      }));

      console.log('Sent connect_channel message for channel:', channelId);
    } catch (error) {
      console.error('Error joining channel:', error);
      connectionStatusStore.set('error');
    }
  }

  async sendMessage(channelId: number, message: string, topicId?: number, attachmentsId?: number, parentId?: number) {
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

    try {
      this.socket.send(JSON.stringify(payload));
    } catch (error) {
      console.error('Error sending message:', error);
      throw new Error('Failed to send message');
    }
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

  leaveChannel(channelId: number) {
    if (!browser) return;
    if (!this.socket || this.socket.readyState !== WebSocket.OPEN) {
      console.error('Cannot leave channel - socket not connected');
      return;
    }

    console.log('Leaving channel:', channelId);
    
    try {
      this.socket.send(JSON.stringify({
        method: 'disconnect_channel',
        channel_id: channelId
      }));
      
      // Clear current channel ID only after successfully sending the message
      this.currentChannelId = null;
      
      // Clear message store
      messagesStore.set([]);
    } catch (error) {
      console.error('Error sending disconnect_channel message:', error);
    }
  }

  private setupConnectionMonitoring() {
    if (!browser) return;
    
    // Clear any existing interval
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
    }
    
    this.monitoringInterval = setInterval(() => {
      if (!this.isVisible || this.isReconnecting) return;
      
      const token = localStorage.getItem('token');
      if (!token) {
        this.cleanupConnection();
        return;
      }

      // Check if token changed
      if (token !== this.currentToken) {
        this.cleanupConnection();
        this.connect(token);
        return;
      }

      // Check if connection dropped unexpectedly
      if (this.socket?.readyState === WebSocket.CLOSED) {
        this.connect(token);
      }
    }, 5000);
  }

  private cleanupConnection() {
    if (this.socket) {
      // Remove all listeners before closing
      this.socket.onopen = null;
      this.socket.onmessage = null;
      this.socket.onclose = null;
      this.socket.onerror = null;

      if (this.socket.readyState === WebSocket.OPEN) {
        // Only try to send close frame if the connection is open
        this.socket.close(1000, 'Client disconnecting');
      }
      this.socket = null;
    }

    this.currentChannelId = null;
    this.isReconnecting = false;
    connectionStatusStore.set('disconnected');
  }

  disconnect() {
    this.isVisible = false;
    this.cleanupConnection();
    
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
    
    messagesStore.set([]);
    typingUsersStore.set(new Set());
    chatParticipantsStore.set(new Map());
  }
}

export const websocketService = new WebSocketService(); 