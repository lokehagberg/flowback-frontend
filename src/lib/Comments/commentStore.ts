import type { Comment, proposal } from '$lib/Poll/interface';
import { writable, get } from 'svelte/store';
import { fetchRequest } from '$lib/FetchRequest';

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
        update,
        get: () => get({ subscribe }),
        setAll: (comments: Comment[]) =>
            update(store => ({
                ...store,
                allComments: comments,
                filteredComments: store.filterByProposal
                    ? comments?.filter(comment =>
                        comment.message?.includes(`#${store.filterByProposal?.title.replaceAll(' ', '-')}`)
                    )
                    : comments
            })),
        add: (comment: Comment) =>
            update(store => ({
                ...store,
                allComments: insertFilteredComments(store.allComments, comment),
                filteredComments: store.filterByProposal && comment.message?.includes(`#${store.filterByProposal.title.replaceAll(' ', '-')}`)
                    ? insertFilteredComments(store.filteredComments, comment)
                    : insertFilteredComments(store.allComments, comment)
            })),
        clear: () =>
            set({
                allComments: [],
                filteredComments: [],
                filterByProposal: null
            }),
    };
}

function insertFilteredComments(comments: Comment[], newComment: Comment) {
    // Check if the comment already exists
    const existingComment = comments?.find(comment => comment.id === newComment.id);
    if (existingComment) {
        console.warn(`Comment with ID ${newComment.id} already exists. Skipping insertion.`);
        return comments; // Return the original array without changes
    }

    if (newComment.parent_id) {
        // Find the parent comment
        const parentIndex = comments?.findIndex(comment => comment.id === newComment.parent_id);

        if (parentIndex !== -1) {
            // Set the reply_depth to one more than the parent's reply_depth
            newComment.reply_depth = comments[parentIndex].reply_depth + 1;

            // Insert the new comment directly below the parent
            comments?.splice(parentIndex + 1, 0, newComment);
        }
    } else {
        // If it's a top-level comment, set reply_depth to 0 and add it to the beginning
        newComment.reply_depth = 0;
        comments?.unshift(newComment);
    }

    return comments;
}

// Function to filter comments by selected proposal tags
// TODO: Make it more efficient. Right now it's putting duplicates and then filtering them out, aswell as ordering them (potentially unecessarily)
// TODO: Avoid n+1 API problem with calling ancestor on every comment
export const filterByTags = async (proposals: proposal[], selectedProposals: number[], pollId: number | string) => {
    let loading = true;
    let toKeep: Comment[] = [];
    const tags = proposals
        .filter((p) => selectedProposals.find((sp) => sp === p.id))
        .map((p) => `#${p.title.replaceAll(' ', '-')}`);

    for (const comment of commentsStore.get().allComments) {
        const { res, json } = await fetchRequest(
            'GET',
            `group/poll/${pollId}/comment/${comment.id}/ancestor`
        );

        if (!res.ok) {
            loading = false;
            // ErrorHandlerStore.set({ message: 'Failed to filter comments', success: false });
            return;
        }

        const ancestors: Comment[] = json.results;

        // Keep ancestor trees such that they contain at least one of the selected tags
        if (ancestors.some((_comment) => tags.some((tag) => _comment.message?.includes(tag))))
            toKeep = [...toKeep, ...ancestors];
    }

    // Filter Duplicates
    toKeep = toKeep.filter((comment) => toKeep.some((c) => c.id === comment.id));

    let toKeepOrdered: Comment[] = [];
    commentsStore.get().allComments.forEach((comment) => {
        toKeep.find((c) => c.id === comment.id) ? toKeepOrdered.push(comment) : null;
    });

    commentsStore.update((store) => ({ ...store, filteredComments: toKeepOrdered }));
    loading = false;
};

export const commentsStore = createCommentStore();