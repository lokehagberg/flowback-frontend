import { checkForLinks } from '$lib/Generic/GenericFunctions';
import type { Comment } from '$lib/Poll/interface';

export const commentSetup = async (comments: Comment[]) => {
	comments.map((comment) => (comment.reply_depth = getCommentDepth(comment, comments)));
	comments.forEach((comment) => {
		checkForLinks(comment.message, `comment-${comment.id}`);
	});

	return comments;
};

const getCommentDepth = (comment: Comment, comments: Comment[]): number => {
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
