const formatDate = (date: string) => {
    let _date = new Date(date);

    return `${_date.getFullYear()}-${_date.getMonth() < 9 ? '0' : ''}${_date.getMonth() + 1}-${
        _date.getDate() < 10 ? '0' : ''
    }${_date.getDate()}`;
};

export default formatDate