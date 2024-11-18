import test from '@playwright/test'

test('poll process', async ({ page }) => {
    await page.goto(`/groups`);
    // await page.click('button[id="groups"]')
})