import { checkForLinks } from '$lib/Generic/GenericFunctions';
import type { Comment } from '$lib/Poll/interface';
import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
import { fetchRequest } from '$lib/FetchRequest';

export const commentSetup = async (comments: Comment[]) => {
	comments.map((comment) => (comment.reply_depth = getCommentDepth(comment, comments)));
	comments.forEach((comment) => {
		checkForLinks(comment.message, `comment-${comment.id}`);
	});

	return comments;
};

export const getCommentDepth = (comment: Comment, comments: Comment[]): number => {
	let depth: number = 0;

	if (comment.parent_id === null) return 0;
	else {
		let parentComment = comments.find((_comment) => _comment.id === comment.parent_id);
		if (parentComment)
			if (parentComment.reply_depth) return parentComment.reply_depth + 1;
			else return getCommentDepth(parentComment, comments) + 1;
	}

	return depth;
};

export const getComments = async (
	id: number | string,
	api: 'poll' | 'thread' | 'delegate-history'
) => {
	let _api = '';

	if (api === 'poll') _api += `group/poll/${id}`;
	else if (api === 'thread') _api += `group/thread/${id}`;
	else if (api === 'delegate-history') _api += `group/delegate/pool/${1}`;

	_api += `/comment/list?limit=${pollCommentsLimit}`;

	const { res, json } = await fetchRequest('GET', _api);

	return json.results.map((comment: Comment) => {
		comment.being_edited = false;
		comment.being_replied = false;
		return comment;
	});
};
