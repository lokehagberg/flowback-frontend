import { writable } from "svelte/store";

export const darkModeStore = writable(false)
let darkMode = false;
darkModeStore.subscribe(mode => darkMode = mode)

export const TriggerDarkMode = () => {
    if (
        localStorage.theme === 'dark' ||
        (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)
    ) {
        document.documentElement.classList.add('dark');
        document.body.classList.add("bg-darkbackground")
        darkModeStore.set(true)

    } else {
        document.documentElement.classList.remove('dark');
        document.body.classList.add("bg-purple-50")
        darkModeStore.set(false)

    }
};

export const changeDarkMode = (changeTo: 'light' | 'dark') => {
    localStorage.theme = changeTo;
    document.documentElement.classList.add(changeTo);
    document.documentElement.classList.remove(changeTo === 'light' ? 'dark' : 'light');
    document.body.classList.add(changeTo === 'dark' ? "bg-darkbackground" : "bg-purple-50")
    document.body.classList.remove(changeTo === 'light' ? "bg-darkbackground" : "bg-purple-50")
    darkModeStore.set(changeTo === 'dark')
}

export const getIconFilter = (isSelected: boolean, color: 'white' | 'blue' = 'blue') => {

    if (color === 'blue')
        if (darkMode) {
            if (isSelected)
                return 'invert(31%) sepia(100%) saturate(10000%) hue-rotate(200deg) brightness(150%) contrast(80%)';
            else
                return 'invert(31%) sepia(0%) saturate(0%) hue-rotate(200deg) brightness(150%) contrast(80%)';
        }
        else {
            if (isSelected)
                return 'invert(31%) sepia(93%) saturate(1410%) hue-rotate(197deg) brightness(91%) contrast(101%)'; // #015BC0
            else
                return 'brightness(0)'
        }
    else if (color === 'white')
        if (darkMode)
            return 'invert(310%) sepia(0%) saturate(10%) hue-rotate(200deg) brightness(150%) contrast(80%)';
        else
            return 'brightness(0)'

    // if (localStorage.getItem("theme") === "dark") {
    //     if (color === 'blue' && isSelected)
    //         return 'invert(31%) sepia(100%) saturate(10000%) hue-rotate(200deg) brightness(150%) contrast(80%)';
    //     else if (!isSelected)
    //         return 'invert(310%) sepia(0%) saturate(10%) hue-rotate(200deg) brightness(150%) contrast(80%)';
    //     else if (color === 'white')
    // }
    // else if (isSelected)
    // else return 'brightness(0)';
};