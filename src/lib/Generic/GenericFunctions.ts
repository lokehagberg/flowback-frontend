//Hack to create a deep copy of an object
export const copyObject = (object:object) => {
    return JSON.parse(JSON.stringify(object))
}

