// This file sadly has to exist because of issues with playwright and sveltekit. Keep track of this GitHub issue to see if fixed:
// https://github.com/sveltejs/kit/issues/1485

// The comment above is not relevant anymore. TODO: Move this function to GenericFunctions.ts and delete this file
export const idfy = (text: string) => {
	return text.trim().replace(/\s+/g, '-').toLowerCase();
};
