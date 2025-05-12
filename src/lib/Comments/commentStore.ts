import type { Comment } from '$lib/Poll/interface';
import { writable, derived } from 'svelte/store';

function createCommentStore() {
    const { subscribe, set, update } = writable<Comment[]>([]);

    return {
        subscribe,
        set,
        add: (comment: Comment) => update(comments => [...comments, comment]),
        remove: (id: number) => update(comments => comments.filter(c => c.id !== id)),
        edit: (id: number, content: string) => update(comments =>
            comments.map(c => c.id === id ? { ...c, content } : c)
        ),
        filterByProposal: (proposalTitle: string) => derived(
            { subscribe },
            $comments => $comments.filter(c => c.message?.includes(`#${proposalTitle}`))
        ),
        clear: () => set([])
    };
}

export const commentsStore = createCommentStore();