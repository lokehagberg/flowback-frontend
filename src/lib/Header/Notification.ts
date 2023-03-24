export interface notification {
    action: 'update';
    channel_category: 'poll';
    channel_id: number;
    channel_sender_id: number;
    channel_sender_type: 'group';
    id: number;
    message: string;
    object_id: number;
    read: boolean;
    timestamp: string;
    
}