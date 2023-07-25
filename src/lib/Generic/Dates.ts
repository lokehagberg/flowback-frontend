export const addDateOffset = (originalDate: Date, offsetValue: number, offsetUnit: 'year' | 'month' | 'day' | 'hour' | 'minute' | 'second'): Date => {
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
        throw new Error('Invalid offset unit. Supported units are: year, month, day, hour, minute, second');
    }
  
    return newDate;
  }