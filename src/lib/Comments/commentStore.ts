import type { Comment } from '$lib/Poll/interface';
import { writable, derived, get } from 'svelte/store'

function createCommentStore() {
  const { subscribe, set, update } = writable<Comment[]>([]);

  return {
    subscribe,
    set,
    add: (comment: Comment) =>
      update((comments) => {
        const exists = comments.some((c) => c.id === comment.id)
        if (!exists) {
          return [...comments, comment]
        }
        return comments
      }),
    remove: (id: number) => update((comments) => comments.filter((c) => c.id !== id)),
    edit: (id: number, content: string) =>
      update((comments) => comments.map((c) => (c.id === id ? { ...c, message: content } : c))),
    filterByProposal: (proposalTitle: string) => {
      const hashtag = `#${proposalTitle.replaceAll(" ", "-")}`
      return derived({ subscribe }, ($comments) => $comments.filter((c) => c.message && c.message.includes(hashtag)))
    },
    getCommentCountForProposal: (proposalTitle: string) => {
      const hashtag = `#${proposalTitle.replaceAll(" ", "-")}`
      const comments = get({ subscribe })
      return comments.filter((c) => c.message && c.message.includes(hashtag)).length
    },
    clear: () => set([])
  };
}

export const commentsStore = createCommentStore();