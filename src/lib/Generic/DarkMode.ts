export const TriggerDarkMode = () => {
    // On page load or when changing themes, best to add inline in `head` to avoid FOUC
    if (
        localStorage.theme === 'dark' ||
        (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)
    ) {
        document.documentElement.classList.add('dark');
        document.body.classList.add("bg-darkbackground")
    } else {
        document.documentElement.classList.remove('dark');
        document.body.classList.add("bg-purple-50")
    }
    
};

export const changeDarkMode = (changeTo:'light'|'dark') => {
    localStorage.theme = changeTo;
    document.documentElement.classList.add(changeTo);
    document.documentElement.classList.remove(changeTo === 'light' ? 'dark' : 'light');
    document.body.classList.add(changeTo === 'dark' ? "bg-darkbackground" : "bg-purple-50")
    document.body.classList.remove(changeTo === 'light' ? "bg-darkbackground" : "bg-purple-50")
}