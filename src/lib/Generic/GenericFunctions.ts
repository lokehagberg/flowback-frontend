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

export const checkForLinks = (text: string, id: string) => {
	if (text === null) return '';

	const linkPattern = /https?:\/\/[^\s]+/g;
	const linkified = text.replace(linkPattern, (match) => {
		return `<a href="${match}" target="_blank">${match}</a>`;
	});

	const descriptionHtmlElement = document.getElementById(id);
	if (descriptionHtmlElement !== null) descriptionHtmlElement.innerHTML = linkified;
};

export const blobifyImages = async (profileImagePreview: any) => {
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
}

// User data is stored as the user navigates the site
// When User enters a group, group user info and permissions about the user is taken in
export let userInfo = writable<UserInfo>();

export const getUserInfo = async () => {
	const { res, json } = await fetchRequest(
		'GET',
		`user`
	);
	return json.results
};