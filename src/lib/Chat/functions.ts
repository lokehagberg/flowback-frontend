import { fetchRequest } from "$lib/FetchRequest";

export const updateUserData = async (selectedChat:number, timestamp?: Date | null, closed?: Date | null) => {
    let data: any = {
        channel_id: selectedChat
    };

    if (timestamp) data.timestamp = timestamp;
    if (closed) data.closed = closed;

    const { res, json } = await fetchRequest('POST', `chat/message/channel/userdata/update`, data);
};