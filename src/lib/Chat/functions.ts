import { fetchRequest } from '$lib/FetchRequest';
import { writable, get } from 'svelte/store';
import type { PreviewMessage } from './interfaces';

export const updateUserData = async (selectedChat: number, timestamp?: Date | null, closed?: Date | null) => {
    let data: any = {
        channel_id: selectedChat
    };

    if (timestamp) data.timestamp = timestamp;
    if (closed) data.closed = closed;

    const { res, json } = await fetchRequest('POST', `chat/message/channel/userdata/update`, data);
};

export const getUserChannelId = async (userId: number) => {
    const { json, res } = await fetchRequest('GET', `user/chat?target_user_ids=${userId}`);

    if (!res.ok || json.length === 0) {
        return;
    }
    return json.id;
};

export const fixDirectMessageChannelName = (previews: PreviewMessage[], userId: undefined | number) => {
    if (userId === undefined) previews;

    previews.map((preview) => {
        if (preview.recent_message?.channel_origin_name === 'user')
            preview.channel_title = preview.participants.find((participant) => participant.id !== userId)?.username;
    });
    return previews;
};

// Store that holds whether the chat is open or closed
export const chatOpenStore = writable(false);

// Store to hold the chat_id or message_id of the chatter being talked to.
const createChatPartnerStore = () => {
    const { subscribe, set, update } = writable<number | null>(0);

    return {
        set,
        update,
        subscribe,
        get: () => get({ subscribe })
    };
};

export const chatPartnerStore = createChatPartnerStore();

export const previewStore = writable<PreviewMessage[]>([]);
