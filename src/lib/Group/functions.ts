import { fetchRequest } from '$lib/FetchRequest';
import type { GroupUser, Tag } from './interface';
import { tags as tagLimit } from '../Generic/APILimits.json';

export const getTags = async (
	groupId: string | number,
	params: string = '',
	sort = true
): Promise<Tag[]> => {
	let tags: Tag[];

	const { res, json } = await fetchRequest(
		'GET',
		`group/${groupId}/tags?limit=${tagLimit}&${params}`
	);
	tags = json?.results;

	if (res.ok && sort) {
		//Sorts tags alphabetically
		tags = json?.results.sort((tag1: Tag, tag2: Tag) => tag1.name.localeCompare(tag2.name));
	}

	return tags;
};


export const setUserGroupPermissionInfo = async (user: GroupUser | null) => {
	if (!user) return;
	if (!user.group_id) return;

	if (user.is_admin) {
		const permissionInfo = {
			allow_delegate: true,
			allow_vote: true,
			ban_members: true,
			create_kanban_task: true,
			create_poll: true,
			create_proposal: true,
			delete_kanban_task: true,
			delete_proposal: true,
			force_delete_comment: true,
			force_delete_poll: true,
			force_delete_proposal: true,
			id: 0,
			invite_user: true,
			kick_members: true,
			poll_fast_forward: true,
			poll_quorum: true,
			prediction_bet_create: true,
			prediction_bet_delete: true,
			prediction_bet_update: true,
			prediction_statement_create: true,
			prediction_statement_delete: true,
			role_name: 'Admin',
			send_group_email: true,
			update_kanban_task: true,
			update_proposal: true
		};
		return permissionInfo;
	}

	const { res, json } = await fetchRequest(
		'GET',
		`group/${user.group_id}/permissions?id=${user.permission_id}`
	);

	if (!res.ok) return;
	const permissionInfo = json?.results ? json?.results[0] : null;
	return permissionInfo;
};