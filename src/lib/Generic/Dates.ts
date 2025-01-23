export const addDateOffset = (
	originalDate: Date,
	offsetValue: number,
	offsetUnit: 'year' | 'month' | 'day' | 'hour' | 'minute' | 'second'
): Date => {
	const newDate = new Date(originalDate.getTime()); // Clone the original date

	switch (offsetUnit) {
		case 'year':
			newDate.setFullYear(newDate.getFullYear() + offsetValue);
			break;
		case 'month':
			newDate.setMonth(newDate.getMonth() + offsetValue);
			break;
		case 'day':
			newDate.setDate(newDate.getDate() + offsetValue);
			break;
		case 'hour':
			newDate.setHours(newDate.getHours() + offsetValue);
			break;
		case 'minute':
			newDate.setMinutes(newDate.getMinutes() + offsetValue);
			break;
		case 'second':
			newDate.setSeconds(newDate.getSeconds() + offsetValue);
			break;
		default:
			throw new Error(
				'Invalid offset unit. Supported units are: year, month, day, hour, minute, second'
			);
	}

	return newDate;
};

export const setDateToMidnight = (date: Date) => {
	const startDateAtMidnight = addDateOffset(
		addDateOffset(date, -date.getHours(), 'hour'),
		-date.getMinutes(),
		'minute'
	);
	return startDateAtMidnight;
};

// This script is released to the public domain and may be used, modified and
// distributed without restrictions. Attribution not necessary but appreciated.
// Source: https://weeknumber.com/how-to/javascript

// Returns the ISO week of the date.
export const getWeek = (date: Date) => {
	var date = new Date();
	date.setHours(0, 0, 0, 0);
	// Thursday in current week decides the year.
	date.setDate(date.getDate() + 3 - ((date.getDay() + 6) % 7));
	// January 4 is always in week 1.
	var week1 = new Date(date.getFullYear(), 0, 4);
	// Adjust to Thursday in week 1 and count number of weeks from date to week1.
	return (
		1 +
		Math.round(((date.getTime() - week1.getTime()) / 86400000 - 3 + ((week1.getDay() + 6) % 7)) / 7)
	);
};

// Returns the four-digit year corresponding to the ISO week of the date.
export const getWeekYear = (date: Date) => {
	var date = new Date();
	date.setDate(date.getDate() + 3 - ((date.getDay() + 6) % 7));
	return date.getFullYear();
};

export const getMonday = (d: Date) => {
	d = new Date(d);
	var day = d.getDay(),
		diff = d.getDate() - day + (day == 0 ? -6 : 1); // adjust when day is sunday
	return new Date(d.setDate(diff));
};

console.log(getMonday(new Date())); // e.g. Mon Nov 08 2010
