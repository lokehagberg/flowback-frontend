import type { Comment } from '$lib/Poll/interface';
import { pollComments as pollCommentsLimit } from '../Generic/APILimits.json';
import { fetchRequest } from '$lib/FetchRequest';

//Uses recursion
export const getCommentDepth = (comment: Comment, comments: Comment[]): number => {
	let depth: number = 0;

	if (comment.parent_id === null) return 0;
	else {
		let parentComment = comments?.find((_comment) => _comment.id === comment.parent_id);
		if (parentComment)
			if (parentComment.reply_depth) return parentComment.reply_depth + 1;
			else return getCommentDepth(parentComment, comments) + 1;
	}

	return depth;
};

//Calls the get comment API to 
export const getComments = async (
	id: number | string | null | undefined,
	api: 'poll' | 'thread' | 'delegate-history',
	offset = 0,
	sortBy: string | null = null,
	searchString: string = ''
) => {
	let _api = '';

	if (api === 'poll') _api += `group/poll/${id}`;
	else if (api === 'thread') _api += `group/thread/${id}`;
	else if (api === 'delegate-history') _api += `group/delegate/pool/${id}`;

	_api += `/comment/list?limit=${pollCommentsLimit}`;
	_api += `&offset=${offset}`;
	if (sortBy !== null) _api += `&order_by=${sortBy}`;
	if (searchString !== '') _api += `&message__icontains=${searchString}`;

	const { res, json } = await fetchRequest('GET', _api);

	return {
		comments: json?.results?.map((comment: Comment) => {
			comment.being_edited = false;
			comment.being_replied = false;
			comment.being_reported = false;
			return comment;
		}),
		next: json.next
	};
};

export async function reportComment(commentId: number, description: string,){
	const {res,json} = await fetchRequest('POST',`report/create`,{
		title:commentId,
		description
	},true)
	console.log(res,json)
	if(!res.ok) return {success:false,message:'Failed to report comment, try again later'}

	return {success:true,message:'Comment has been reported'}
}