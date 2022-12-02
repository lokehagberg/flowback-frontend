import { sveltekit } from '@sveltejs/kit/vite';


/** @type {import('vite').UserConfig} */
const config = {
    plugins: [sveltekit()],
    optimizeDeps: {
        exclude: ['chart.js']
    },
    server: {
        port: import.meta.env.PORT
    }
};

export default config;