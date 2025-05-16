import type { Comment, proposal } from '$lib/Poll/interface';
import { writable } from 'svelte/store';

function createCommentStore() {
    const { subscribe, set, update } = writable<{
        allComments: Comment[];
        filteredComments: Comment[];
        filterByProposal: proposal | null;
    }>({
        allComments: [],
        filteredComments: [],
        filterByProposal: null
    });

    return {
        subscribe,
        setAll: (comments: Comment[]) =>
            update(store => ({
                ...store,
                allComments: comments,
                filteredComments: store.filterByProposal
                    ? comments.filter(comment =>
                        comment.message?.includes(`#${store.filterByProposal?.title}`)
                    )
                    : comments
            })),
        add: (comment: Comment) =>
            update(store => ({
                ...store,
                allComments: [...store.allComments, comment],
                filteredComments: store.filterByProposal && comment.message?.includes(`#${store.filterByProposal.title}`)
                    ? [...store.filteredComments, comment]
                    : [...store.allComments, comment]
            })),
        filterByProposal: (proposal: proposal | null) =>
            update(store => ({
                ...store,
                filterByProposal: proposal || null,
                filteredComments: proposal
                    ? store.allComments.filter(comment =>
                        comment.message?.includes(`#${proposal.title}`))
                    : store.allComments
            })),
        getProposal: () => (
            subscribe(store => {
                return store.filterByProposal
            }
        )),
        getAll: () => {
            let allComments: Comment[] = [];
            update(store => {
                allComments = store.allComments;
                return store;
            });
            return allComments;
        },
        clear: () =>
            set({
                allComments: [],
                filteredComments: [],
                filterByProposal: null
            })
    };
}

export const commentsStore = createCommentStore();