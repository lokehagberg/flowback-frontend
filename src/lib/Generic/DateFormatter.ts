//DEPRICATED
//TODO: Apparently there's built in javascript functions for formatting dates, use that instead.
export const formatDate = (dateInput: Date | string | undefined) => {
	if (dateInput === undefined) return '';
	const date = new Date(dateInput);
	return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}  ${
		date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
	}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

export const maxDatePickerYear = new Date((new Date().getFullYear() + 5).toString());