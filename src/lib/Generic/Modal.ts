import { writable } from 'svelte/store'

export const numberOfModalOpen = writable(0);

numberOfModalOpen.subscribe((value) => {
    console.log(value)
})

// count.set(1)

// count.update((n) => n + 1 )