import { writable } from 'svelte/store';

export const isMobile = writable(false);

if (typeof window !== 'undefined') {
	const checkMobile = () => isMobile.set(window.innerWidth < 768);

	checkMobile();
	window.addEventListener('resize', checkMobile);

	if (import.meta.hot) {
		import.meta.hot.dispose(() => window.removeEventListener('resize', checkMobile));
	}
}
