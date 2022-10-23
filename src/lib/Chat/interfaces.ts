export interface Message {
    message:string;
    user:{
        id:number,
        username:string,
        profile_image:File
    }
}