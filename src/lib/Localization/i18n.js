/**
 * Reference: https://github.com/kaisermann/svelte-i18n/blob/HEAD/docs/Getting%20Started.md
 */
import { addMessages, init, register } from 'svelte-i18n';

import en from './en.json';
import se from './se.json';

addMessages('en', en);
addMessages('en', se);