import { checkForLinks } from '$lib/Generic/GenericFunctions';
import type { Comment } from '$lib/Poll/interface';
import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
import { fetchRequest } from '$lib/FetchRequest';
import { commentsStore } from './commentStore'

export const commentSetup = async (comments: Comment[]) => {
  if (!comments) return [];

  comments.map((comment) => (comment.reply_depth = getCommentDepth(comment, comments)));
  comments.forEach((comment) => {
    if (comment.message) {
      checkForLinks(comment.message, `comment-${comment.id}`);
    }
  });

  return comments;
};

//Uses recursion
export const getCommentDepth = (comment: Comment, comments: Comment[]): number => {
  if (comment.parent_id === null) return 0;

  const parentComment = comments.find((_comment) => _comment.id === comment.parent_id)
  if (parentComment) {
    if (typeof parentComment.reply_depth === 'number') {
      return parentComment.reply_depth + 1
    } else {
      return getCommentDepth(parentComment, comments) + 1
    }
  }

  return 0
}

//Calls the get comment API to
export const getComments = async (
  id: number | string | null | undefined,
  api: 'poll' | 'thread' | 'delegate-history',
  offset = 0,
  sortBy: string | null = null,
  searchString = '',
) => {
  let _api = '';

  if (api === 'poll') _api += `group/poll/${id}`;
  else if (api === 'thread') _api += `group/thread/${id}`;
  else if (api === 'delegate-history') _api += `group/delegate/pool/${id}`;

  _api += `/comment/list?limit=${pollCommentsLimit}`;
  _api += `&offset=${offset}`;
  if (sortBy !== null) _api += `&order_by=${sortBy}`;
  if (searchString !== '') _api += `&message__icontains=${searchString}`;

  try {
    const { res, json } = await fetchRequest('GET', _api)

    if (!res.ok) {
      console.error('Failed to fetch comments:', json)
      return { comments: [], next: null }
    }

    const comments =
      json.results?.map((comment: Comment) => {
        comment.being_edited = false
        comment.being_replied = false
        comment.being_reported = false
        return comment
      }) || []

    return {
      comments,
      next: json.next,
    }
  } catch (error) {
    console.error('Error fetching comments:', error)
    return { comments: [], next: null }
  }
}

export const countCommentsForProposal = (proposalTitle: string) => {
  return commentsStore.getCommentCountForProposal(proposalTitle)
}

export async function reportComment(commentId: number, description: string) {
  try {
    const { res, json } = await fetchRequest(
      'POST',
      `report/create`,
      {
        title: commentId,
        description,
      },
      true,
    )

    if (!res.ok) {
      return { success: false, message: 'Failed to report comment, try again later' }
    }

    return { success: true, message: 'Comment has been reported' }
  } catch (error) {
    console.error('Error reporting comment:', error)
    return { success: false, message: 'An error occurred while reporting the comment' }
  }
}

export const getFileType = (fileName: string): 'image' | 'pdf' | 'txt' | 'other' => {
  const ext = fileName.split('.').pop()?.toLowerCase()

  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].includes(ext || '')) {
    return 'image'
  } else if (ext === 'pdf') {
    return 'pdf'
  } else if (ext === 'txt') {
    return 'txt'
  } else {
    return 'other'
  }
}

export const getFileName = (filePath: string): string => {
  const parts = filePath.split('/')
  return parts[parts.length - 1]
}
