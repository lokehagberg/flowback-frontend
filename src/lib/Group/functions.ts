import { fetchRequest } from '$lib/FetchRequest';
import type { Tag } from './interface';
import { tags as tagLimit } from '../Generic/APILimits.json';

export const getUserIsOwner = async (groupId: number | string) => {
	const userData = await fetchRequest('GET', 'user');
	const groupAdmins = await fetchRequest('GET', `group/${groupId}/users?is_admin=true`);

	if (userData && groupAdmins)
	return (
		groupAdmins.json.results.find(
			(user: any) => user.user.id === userData.json.id && user.is_admin
		) !== undefined
	);
};

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
	tags = json.results;

	if (res.ok && sort) {
		//Sorts tags alphabetically
		tags = json.results.sort((tag1: Tag, tag2: Tag) => tag1.name.localeCompare(tag2.name));
	}

	// else if (!res.ok) {
	// 	let poppup: poppup = { show: true, message: 'Could not get tags', success: false };
	// 	return poppup;
	// }

	return tags;
};
