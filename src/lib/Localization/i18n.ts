/**
 * Reference: https://github.com/kaisermann/svelte-i18n/blob/HEAD/docs/Getting%20Started.md
 */
import { addMessages, init, register, dictionary, locale, _ } from 'svelte-i18n';

import en from './en.json';
import se from './se.json';


export const initializeLocalization = () => {
    addMessages('en', en);
    addMessages('sv', se);

    //Avoids navigator not found error
    const initialLocale = typeof navigator !== 'undefined' ? navigator.language : 'en';

    init({
        fallbackLocale: 'en',
        initialLocale
    });
}