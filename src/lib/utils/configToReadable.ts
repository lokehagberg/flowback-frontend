export function configToReadable(key: string): string {
    switch (key) {
        // Notification Schedule
        case 'invited_to_event': return 'I am invited to an event';
        case 'event_date_changed': return "an event's date has been changed";
        case 'event_canceled': return 'an event has been canceled';
        case 'new_member_added': return 'a new member has been added';
        case 'event_frequency_changed': return "an event's frequency has been changed";

        // Notification Kanban
        case 'task_assigned': return 'a task is assigned to you';
        case 'task_priority_changed': return "a task's priority is changed";
        case 'task_status_changed': return "a task's status is changed";

        // Notification Posts
        case 'new_thread_created': return 'a new thread is created';
        case 'new_poll_created': return 'a new poll is created';
        case 'vote_on_comment': return 'someone votes on my comment';

        // Poll Settings
        case 'area_voting': return 'Area voting';
        case 'proposal_creation': return 'Proposal creation';
        case 'prediction_statement_creation': return 'Prediction statement creation';
        case 'prediction_betting': return 'Prediction betting';
        case 'delegate_voting': return 'Delegate voting';
        case 'voting': return 'Voting';

        // Sections
        case 'schedule': return 'Schedule';
        case 'kanban': return 'Kanban';
        case 'posts': return 'Posts';

        default: return key.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
    }
}