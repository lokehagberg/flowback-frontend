import { fetchRequest } from "$lib/FetchRequest";

export const getUserIsOwner = async (groupId:number|string) => {
    const userData = await fetchRequest('GET', 'user');
    const groupAdmins = await fetchRequest(
        'GET',
        `group/${groupId}/users?is_admin=true`
    );

    return groupAdmins.json.results.find(
            (user: any) => user.user.id === userData.json.id && user.is_admin
        ) !== undefined;
};
