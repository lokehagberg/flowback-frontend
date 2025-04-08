import { apiClient } from './client';

// Types
export type PublicStatusEnum = 'public' | 'group_only' | 'private';
export type ChatStatusEnum = 'public' | 'group_only' | 'private';
export type OrderByEnum = 'created_at_asc' | 'created_at_desc' | 'total_replies_asc' | 'total_replies_desc';
export type MessageOrderByEnum = 'created_at_asc' | 'created_at_desc';

export interface User {
    id: number;
    username: string;
    profile_image: string | null;
    banner_image: string | null;
    public_status: PublicStatusEnum;
    chat_status: ChatStatusEnum;
}

export interface Attachment {
    file: string;
    file_name: string;
}

export interface Message {
    id: number;
    user: User;
    created_at: string;
    updated_at: string;
    channel_id: number;
    channel_origin_name: string;
    channel_title: string;
    topic_id?: number;
    topic_name?: string;
    type: string;
    message: string;
    attachments: Attachment[] | null;
    parent_id?: number;
    parent?: Message;
    active: boolean;
}

export interface PaginatedResponse<T> {
    count: number;
    next: string;
    previous: string;
    total_page: number;
    results: T[];
}

export interface MessageListParams {
    created_at__gte?: string;
    created_at__lte?: string;
    has_attachments?: boolean;
    id?: number;
    limit?: number;
    message__icontains?: string;
    offset?: number;
    order_by?: OrderByEnum;
    parent_id?: number;
    topic_id?: number;
    topic_name?: string;
    user_ids?: string;
}

export interface MessageChannelParticipant {
    id: number;
    user: User;
    active: boolean;
}

export interface MessageChannelTopic {
    id: number;
    name: string;
}

export interface MessageChannelPreview extends Message {
    timestamp: string | null;
    participants: number;
}

export interface UserChatInvite {
    id: number;
    message_channel_name: string;
    message_channel_id: number;
    rejected: boolean | null;
}

// API Functions
export const chat = {
    // Upload files to a channel
    uploadFiles: (channelId: number, files: string[]) =>
        apiClient<void>(`chat/message/channel/${channelId}/file/upload`, {
            method: 'POST',
            body: { files }
        }),

    // Get messages in a channel
    getMessages: (channelId: number, params?: MessageListParams) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== undefined) queryParams.append(key, value.toString());
            });
        }
        const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
        return apiClient<PaginatedResponse<Message>>(`chat/message/channel/${channelId}/list${query}`);
    },

    // Get channel participants
    getParticipants: (channelId: number, params?: {
        active?: boolean;
        id?: number;
        limit?: number;
        offset?: number;
        user_id?: number;
        username__icontains?: string;
    }) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== undefined) queryParams.append(key, value.toString());
            });
        }
        const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
        return apiClient<PaginatedResponse<MessageChannelParticipant>>(`chat/message/channel/${channelId}/participant/list${query}`);
    },

    // Get channel topics
    getTopics: (channelId: number, params?: {
        id?: number;
        limit?: number;
        name?: string;
        name__icontains?: string;
        offset?: number;
        topic_id?: number;
    }) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== undefined) queryParams.append(key, value.toString());
            });
        }
        const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
        return apiClient<PaginatedResponse<MessageChannelTopic>>(`chat/message/channel/${channelId}/topic/list${query}`);
    },

    // Get channel previews
    getChannelPreviews: (params?: {
        channel_id?: number;
        created_at__gte?: string;
        created_at__lte?: string;
        id?: number;
        limit?: number;
        offset?: number;
        order_by?: MessageOrderByEnum;
        origin_names?: string;
        topic_id?: number;
        topic_name?: string;
        user_id?: number;
        username__icontains?: string;
    }) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== undefined) queryParams.append(key, value.toString());
            });
        }
        const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
        return apiClient<PaginatedResponse<MessageChannelPreview>>(`chat/message/channel/preview/list${query}`);
    },

    // Update user channel data
    updateUserChannelData: (data: {
        channel_id: number;
        timestamp?: string;
        closed_at?: string;
    }) =>
        apiClient<void>('chat/message/channel/userdata/update', {
            method: 'POST',
            body: data
        }),

    // Get or create chat channel
    getChatChannel: (targetUserIds: number[], preview = false) => {
        const queryParams = new URLSearchParams();
        queryParams.append('target_user_ids', targetUserIds.join(','));
        if (preview) queryParams.append('preview', 'true');
        return apiClient<{ id: number; title: string; }>(`user/chat?${queryParams.toString()}`);
    },

    // Respond to chat invite
    respondToChatInvite: (inviteId: number, accept: boolean) =>
        apiClient<void>('user/chat/invite', {
            method: 'POST',
            body: { invite_id: inviteId, accept }
        }),

    // List chat invites
    listChatInvites: (params?: {
        limit?: number;
        message_channel_id?: number;
        offset?: number;
        rejected?: boolean;
        rejected__isnull?: boolean;
    }) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.entries(params).forEach(([key, value]) => {
                if (value !== undefined) queryParams.append(key, value.toString());
            });
        }
        const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
        return apiClient<PaginatedResponse<UserChatInvite>>(`user/chat/invite/list${query}`);
    },

    // Create a group chat
    createGroupChat: async (name: string, memberIds: number[]) => {
        // Ensure current user is included
        const currentUserId = Number(localStorage.getItem('userId'));
        const allUserIds = [...new Set([currentUserId, ...memberIds])];
        
        const queryParams = allUserIds.map(id => `target_user_ids=${id}`).join('&');
        return apiClient<{ id: number; title: string; }>(`user/chat?${queryParams}`);
    },

    // Search users for group chat creation
    searchUsers: (query: string) => 
        apiClient<PaginatedResponse<User>>(`users?username__icontains=${encodeURIComponent(query)}&limit=10`),
}; 