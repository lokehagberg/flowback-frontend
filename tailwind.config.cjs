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
                primary: 'var(--primary-color)',
                secondary: 'var(--secondary-color)',
                background: 'var(--background-color)',
                accent: 'var(accent-color)'
            },
            filter: ['hover', 'focus'],
        },
    },
    plugins: [],
}