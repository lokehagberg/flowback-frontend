//Hack to create a deep copy of an object
export const deepCopy = (object: object) => {
	return JSON.parse(JSON.stringify(object));
};

//Used for displaying status (error or success, usually from API requests) to user
export type StatusMessageInfo = {
	message: string | null;
	success: boolean;
};

export const checkForLinks = (text:string, id:string) => {
	const linkPattern = /https?:\/\/[^\s]+/g;
	const linkified = text.replace(linkPattern, (match) => {
		return `<a href="${match}" target="_blank">${match}</a>`;
	});

	const descriptionHtmlElement = document.getElementById(id)
	if (descriptionHtmlElement !== null) descriptionHtmlElement.innerHTML = linkified
};