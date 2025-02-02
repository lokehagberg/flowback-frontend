//DEPRICATED
//TODO: Apparently there's built in javascript functions for formatting dates, use that instead.
export const formatDate = (dateInput: Date | string | undefined) => {


	if (dateInput === undefined) return '';

	const date = new Date(dateInput);

	console.log(date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`);


	return `${date.getFullYear()}-${date.getMonth() + 1 > 9 ? date.getMonth() + 1 : `0${date.getMonth() + 1}`}-${date.getDate() > 9 ? date.getDate() : `0${date.getDate()}`}  ${date.getHours() > 9 ? date.getHours() : `0${date.getHours()}`
		}:${date.getMinutes() > 9 ? date.getMinutes() : `0${date.getMinutes()}`}`;
};

export const maxDatePickerYear = new Date((new Date().getFullYear() + 5).toString());

//@ts-ignore
Date.prototype.getWeek = function () {
	var onejan = new Date(this.getFullYear(), 0, 1);
	var today = new Date(this.getFullYear(), this.getMonth(), this.getDate());
	var dayOfYear = ((today.getTime() - onejan.getTime() + 86400000) / 86400000);
	return Math.ceil(dayOfYear / 7)
};