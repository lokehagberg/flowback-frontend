import {writable}     from 'svelte/store';
import {fetchRequest} from '$lib/FetchRequest';
import {statusMessageFormatter} from '$lib/Generic/StatusMessage';

export const darkModeStore = writable<bool>(false);

export const accountsStore = writable(
	Object.assign([], {loaded: false, asOf: new Date(0)})
);
Object.assign(accountsStore, {
	promiseValue() {
		return new Promise((res, rej)=>
			this.subscribe(res)
		);
	},
	async get() {
		console.log(".get", this);
		let storedVal;
		storedVal = await this.promiseValue();
		console.log("storedVal:", storedVal);
		const oneMinute = 60_000;
		if (
			!storedVal.loaded ||
			Date.now() - storedVal.asOf >= 5*oneMinute
		) {
			const loadedVal = await this.load();
			if (!loadedVal.loaded && storedVal.loaded)
				return storedVal;
			this.set(loadedVal);
			return loadedVal;
		} else
			return storedVal;
	},
	async load() {
		console.log(".load", this);
		const {res, json} =
			await fetchRequest('GET', 'ledger/accounts');
		const status = statusMessageFormatter(res, json);
		if (!res.ok)
			return {
				loaded: false,
				asOf: new Date(),
				status: status
			};
		return Object.assign(json.results, {
			loaded: true,
			asOf: new Date(),
			status: status
		});
	}
});
