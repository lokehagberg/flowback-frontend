//Hack to create a deep copy of an object
export const deepCopy = (object: object) => {
	return JSON.parse(JSON.stringify(object));
};

export type StatusMessageInfo = {
	message: string | null;
	success: boolean;
}
