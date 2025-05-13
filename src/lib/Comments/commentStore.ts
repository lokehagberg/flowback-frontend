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
    edit: (id: number, message: string, attachments?: Array<{ file: string | File }>) => {
      update((store) => {
        const index = store.findIndex((comment) => comment.id === id)
        if (index !== -1) {
          store[index].message = message
          store[index].edited = true
          if (attachments) {
            store[index].attachments = attachments
          }
        }
        return store
      })
    },
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