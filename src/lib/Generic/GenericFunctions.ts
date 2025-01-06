import { fetchRequest } from '$lib/FetchRequest';
import type { GroupUser } from '$lib/Group/interface';
import type { Permission } from '$lib/Group/Permissions/interface';
import type { User } from '$lib/User/interfaces';
import { writable } from 'svelte/store';
import { page } from '$app/stores';

//Hack to create a deep copy of an object
export const deepCopy = (object: object) => {
	return JSON.parse(JSON.stringify(object));
};

//Used for displaying status (error or success, usually from API requests) to user
export type StatusMessageInfo = {
	message: string | null;
	success: boolean;
};

// Makes links clickable. For comments and descriptions
export const checkForLinks = (text: string | null, id: string) => {
	if (text === null) return '';

	const linkPattern = /https?:\/\/[^\s]+/g;
	const linkified = text.replace(linkPattern, (match) => {
		return `<a href="${match}" target="_blank">${match}</a>`;
	});

	const descriptionHtmlElement = document.getElementById(id);
	if (descriptionHtmlElement !== null) descriptionHtmlElement.innerHTML = linkified;
};

export const blobifyImages = async (profileImagePreview: any) => {
	console.log(profileImagePreview, "IMAGE")
	const image = await fetch(profileImagePreview)
		.then((res) => res.blob())
		.then((blob) => {
			const file = new File([blob], 'dot.png', blob);
			return file;
		});

	return image;
};

export const onThumbnailError = (event: any, picture: string) => {
	if (!(event && event.target)) return;
	event.target.src = picture;
	event.onerror = null;
};

interface UserInfo {
	user: User;
	permission?: Permission;
	groupuser?: GroupUser;
	groupId?: number;
}

// User data is stored as the user navigates the site
// When User enters a group, group user info and permissions about the user is taken in
export let userInfo = writable<UserInfo>();

//Get info about user (the information you'd see on the user page)
export const getUserInfo = async () => {
	const { res, json } = await fetchRequest('GET', `user`);
	if (!res.ok) return {};
	return json;
};

//Get info about user as in the group (permissions, is admin, workgroups and the user itself)
export const getGroupUserInfo = async (groupId: number | string) => {
	groupId = Number(groupId);

	const { res, json } = await fetchRequest(
		'GET',
		`group/${groupId}/users?user_id=${localStorage.getItem('userId')}`
	);

	if (!res.ok) return;
	return json.results[0];
};

export const getPermissions = async (groupId: number | string, permissionId: number | string) => {
	groupId = Number(groupId);
	permissionId = Number(permissionId);

	const { res, json } = await fetchRequest(
		'GET',
		`group/${groupId}/permissions?id=${permissionId}`
	);
	return json.results[0];
};

export const elipsis = (label: string, charMax = 30) => {
	return label.length > charMax ? label.substring(0, charMax) + '...' : label
}

// Returns true if user is admin in the given group, false otherwise.
// TODO: Make sure that as the user navigates the site, between different groups, that there will be dynamic loading of it's group user information. Right now the code is a mess! 
export const getUserIsGroupAdmin = async (groupId: number | string) => {
	const userData = await fetchRequest('GET', 'user');
	const groupAdmins = await fetchRequest(
		'GET',
		`group/${groupId}/users?is_admin=true`
	);

	if (groupAdmins.json.results.find(
		(user: any) => user.user.id === userData.json.id && user.is_admin
	) !== undefined)
		return true
	else return false;
};