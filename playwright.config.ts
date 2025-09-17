import type { PlaywrightTestConfig } from '@playwright/test';

const config: PlaywrightTestConfig = {

	//@ts-ignore
	webServer: {
		// command: 'npm run dev5000',
		port: 4000,
		reuseExistingServer: true,
	}

};

export default config;
