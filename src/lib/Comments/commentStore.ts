import type { Comment, proposal } from '$lib/Poll/interface';
import { writable } from 'svelte/store';

function createCommentStore() {
    const { subscribe, set, update } = writable<{
        allComments: Comment[];
        filteredComments: Comment[];
        filterByProposalId: number | null;
    }>({
        allComments: [],
        filteredComments: [],
        filterByProposalId: null
    });

    return {
        subscribe,
        setAll: (comments: Comment[]) =>
            update(store => ({
                ...store,
                allComments: comments,
                filteredComments: store.filterByProposalId
                    ? comments.filter(comment =>
                        comment.message?.includes(`#${store.filterByProposalId}`)
                    )
                    : comments
            })),
        add: (comment: Comment) =>
            update(store => ({
                ...store,
                allComments: [...store.allComments, comment],
                filteredComments: store.filterByProposalId
                    ? [...store.filteredComments, comment]
                    : [...store.allComments, comment]
            })),
        filterByProposal: (proposal: proposal | null) =>
            update(store => ({
                ...store,
                filterByProposalId: proposal?.id || null,
                filteredComments: proposal
                    ? store.allComments.filter(comment =>
                        comment.message?.includes(`#${proposal.title}`))
                    : store.allComments
            })),
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
                filterByProposalId: null
            })
    };
}

export const commentsStore = createCommentStore();