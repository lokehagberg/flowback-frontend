import type { PlaywrightTestConfig } from '@playwright/test';

const config: PlaywrightTestConfig = {

	//@ts-ignore
	webServer: {
		port: 4000,
		reuseExistingServer: true,
	},
	timeout: 30000,
	// workers:1

};

export default config;
