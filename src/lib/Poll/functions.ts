export const formatDate = (dateInput: string) => {
	const date = new Date(dateInput);
	return `${date.getDay()}/${date.getMonth()} ${date.getFullYear()} klockan ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};
