import type { Comment, proposal } from '$lib/Poll/interface';
import { writable } from 'svelte/store';
import type Comments from './Comments.svelte';

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
                allComments: insertFilteredComments(store.allComments, comment),
                filteredComments: store.filterByProposal && comment.message?.includes(`#${store.filterByProposal.title}`)
                    ? insertFilteredComments(store.filteredComments, comment)
                    : insertFilteredComments(store.allComments, comment)
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

function insertFilteredComments(comments: Comment[], newComment: Comment) {
    // Check if the comment already exists
    const existingComment = comments.find(comment => comment.id === newComment.id);
    if (existingComment) {
        console.warn(`Comment with ID ${newComment.id} already exists. Skipping insertion.`);
        return comments; // Return the original array without changes
    }

    if (newComment.parent_id) {
        // Find the parent comment
        const parentIndex = comments.findIndex(comment => comment.id === newComment.parent_id);

        if (parentIndex !== -1) {
            // Set the reply_depth to one more than the parent's reply_depth
            newComment.reply_depth = comments[parentIndex].reply_depth + 1;

            // Insert the new comment directly below the parent
            comments.splice(parentIndex + 1, 0, newComment);
        }
    } else {
        // If it's a top-level comment, set reply_depth to 0 and add it to the beginning
        newComment.reply_depth = 0;
        comments.unshift(newComment);
    }

    return comments;
}

export const commentsStore = createCommentStore();