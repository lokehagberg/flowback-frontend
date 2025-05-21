// interface.ts
export interface scheduledEvent {
    created_by: number;
    description?: string;
    end_date: string;
    event_id: number;
    poll?: number;
    score?: number | null;
    start_date: string;
    title: string;
    group_id?: number;
    work_group?: {
        id: number;
        name: string;
    };
    schedule_origin_name: 'user' | 'group';
    meeting_link?: string;
    repeat_frequency?: number; // 0: Never, 1: Daily, 2: Weekly, 3: Monthly, 4: Yearly, 5: Custom
    assignee_ids?: number[]; // List of assigned group member IDs
    reminders?: number[]; // List of reminder times in seconds
}

export interface WorkGroupScheduledEventCreate {
    title: string;
    description?: string;
    start_date: string;
    end_date?: string;
    group_id: number;
    work_group_id?: number;
    assignee_ids?: number[];
    meeting_link?: string;
    repeat_frequency?: number;
    reminders?: number[];
}