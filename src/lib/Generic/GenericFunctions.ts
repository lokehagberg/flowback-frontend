import { fetchRequest } from '$lib/FetchRequest';
import type { User } from '$lib/User/interfaces';
import { get, writable } from 'svelte/store';
import { groupUserStore, type GroupUser } from '$lib/Group/interface';
import { userStore } from '$lib/User/interfaces';
import type { Permissions } from '$lib/Group/Permissions/interface';

let groupUserInfo: GroupUser | null = null;

groupUserStore.subscribe((value) => {
  groupUserInfo = value;
});

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
  if (text === null || typeof text !== "string") return '';

  const linkPattern = /https?:\/\/[^\s]+/g;
  const linkified = text.replace(linkPattern, (match) => {
    return `<a href="${match}" target="_blank">${match}</a>`;
  });

  const descriptionHtmlElement = document.getElementById(id);
  // SECURITY RISK: HTML INJECTION. TODO: Fix this without the security flaw
  // if (descriptionHtmlElement !== null) descriptionHtmlElement.innerHTML = linkified;
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
  permission?: Permissions;
  groupuser?: GroupUser;
  groupId?: number;
}

// User data is stored as the user navigates the site
// When User enters a group, group user info and permissions about the user is taken in
export let userInfo = writable<UserInfo>();

//Get info about user (the information you'd see on the user page)
export const getUserInfo = async (): Promise<User> => {
  const { res, json } = await fetchRequest('GET', `user`);
  if (!res.ok) return {} as User;
  return json as User;
};

//Get info about user as in the group (permissions, is admin, workgroups and the user itself)
export const getGroupUserInfo = async (groupId: number | string) => {
  groupId = Number(groupId);

  const { res, json } = await fetchRequest(
    'GET',
    `group/${groupId}/users?user_id=${get(userStore)?.id || -1}`
  );

  if (!res.ok) return;
  return json?.results[0];
};

export const getPermissions = async (groupId: number | string, permissionId: number | string) => {
  if (!groupId) return;

  groupId = Number(groupId);
  permissionId = Number(permissionId);

  const { res, json } = await fetchRequest(
    'GET',
    `group/${groupId}/permissions?id=${permissionId}`
  );

  if (!res.ok) return;

  return json?.results[0];
};

export const getPermissionsFast = async (groupId: number | string) => {
  if (!groupUserInfo) return;

  if (groupUserInfo.permission_id) {
    const permissions = await getPermissions(groupId, groupUserInfo.permission_id);
    return permissions
  }
}

export const elipsis = (label: string, charMax = 30) => {
  return label.length > charMax ? label.substring(0, charMax) + '...' : label
}

export const commaCleanup = (api: string) => {
  return api?.replace('%2C', ',');
};

export const linkToPost = (postId: number, groupId: number, postType: 'poll' | 'thread') => {
  let _postType = '';
  if (postType === 'poll') _postType = 'polls';
  if (postType === 'thread') _postType = 'thread';

  return `/groups/${groupId}/${_postType}/${postId}`;
}

export const lazyLoading = (getFunction = () => { }) => {
  const el = document.scrollingElement || document.documentElement;

  const scrolledToBottom =
    el.scrollTop + window.innerHeight >= el.scrollHeight - 1;

  if (scrolledToBottom) getFunction();
};

export const formatDateToLocalTime = (date: Date): string => {
  try {
    const offset = date.setTime(date.getTime() - date.getTimezoneOffset() * 60000);
    return new Date(offset).toISOString();
  } catch (error) {
    console.error('Error converting date to string:', error);
    return date.toString();
  }
};

export function arraysEqual(arr1: any[], arr2: any[]) {
  if (arr1.length !== arr2.length) return false;
  return arr1.every((value, index) => value === arr2[index]);
}

// https://webreflection.medium.com/using-the-input-datetime-local-9503e7efdce
export function toDatetimeLocal(date: Date) {
  var
    ten = function (i: any) {
      return (i < 10 ? '0' : '') + i;
    },
    YYYY = date.getFullYear(),
    MM = ten(date.getMonth() + 1),
    DD = ten(date.getDate()),
    HH = ten(date.getHours()),
    II = ten(date.getMinutes()),
    SS = ten(date.getSeconds())
    ;
  return YYYY + '-' + MM + '-' + DD + 'T' +
    HH + ':' + II + ':' + SS;
};

// export function bst(BST:string) {
//   // BST should not be present as UTC time
//   return new Date(BST).toISOString().slice(0, 16) === BST ?
//     // if it is, it needs to be removed
//     function () {
//       return new Date(
//         this.getTime() +
//         (this.getTimezoneOffset() * 60000)
//       ).toISOString();
//     } :
//     // otherwise can just be equivalent of toISOString
//     Date.prototype.toISOString;
// } ('2006-06-06T06:06'));
