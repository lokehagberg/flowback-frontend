export const formatDate = (dateInput: string | undefined) => {
	if (dateInput === undefined) return '';
	const date = new Date(dateInput);
	return `${date.getFullYear()}-${date.getMonth()}-${date.getDay()}  ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};
