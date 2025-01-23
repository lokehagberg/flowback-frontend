/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: 'class',
    content: ['./src/**/*.{html,js,svelte,ts}'],
    theme: {
        // colors: {
        //     'blue': '#990000',
        //     'red': "#110022"
        // },
        extend: {
            colors: {
                // These colors are findable in app.css
                primary: 'var(--primary)',
                secondary: 'var(--secondary)',
                background: 'var(--background)',
                accent: 'var(--accent)',
                'accent-secondary': 'var(--accent-secondary)',
                'accent-tertiary': 'var(--accent-tertiary)',
                darkmodeText: 'var(--darkmode-text-color)',
                darkbackground: 'var(--darkmode-background-color)',
                darkobject: 'var(--darkmode-object-color)',
            },
            filter: ['hover', 'focus'],
        },
    },
    plugins: [],
}