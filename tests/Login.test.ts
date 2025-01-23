import { expect, test } from '@playwright/test';

test('login', async ({ page }) => {
    await page.goto(`/login`);

    await page.fill('input[name="email"]', 'a@a.se');
    await page.fill('input[name="password"]', 'a');

    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/home');


});