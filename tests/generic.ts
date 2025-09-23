import { chromium, expect } from '@playwright/test';

export async function newWindow() {
    const browser = await chromium.launch();
    const Context = await browser.newContext();
    const Page = await Context.newPage();
    return Page
}

export async function login(page: any, {
    email = process.env.E2E_EMAIL ?? 'flowback@flowback.org',
    password = process.env.E2E_PASSWORD ?? 'flowbacco',
} = {}) {
    await page.goto('https://immr.flowback.org/login');
    await expect(page.locator('#login-page')).toBeVisible();
    await page.waitForTimeout(700);

    await page.fill('input[name="email"]', email);
    await page.fill('input[name="password"]', password);
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('https://immr.flowback.org/home?chatOpen=false');

    if (await page.getByRole('button', { name: 'Ok' }).isVisible()) {
        await page.getByRole('button', { name: 'Ok' }).click();
    }
}

export async function loginEnter(page: any, {
    email = process.env.E2E_EMAIL ?? 'a@a.se',
    password = process.env.E2E_PASSWORD ?? 'a',
} = {}) {
    await page.goto('/login');
    await expect(page.locator('#login-page')).toBeVisible();
    await page.waitForTimeout(700);

    await page.fill('input[name="email"]', email);
    await page.fill('input[name="password"]', password);
    await page.getByLabel('Password * 1/').press('Enter');

    await expect(page).toHaveURL('/home?chatOpen=false');
}

// Tests registring a user
// Only works if PUBLIC_EMAIL_REGISTRATION=FALSE in .env
// Email functionality appears to only be manually testable afaik 
export async function register(page: any) {
    await page.goto('/login');
    await expect(page.locator('#login-page')).toBeVisible();
    await page.waitForTimeout(500);

    await page.getByRole('button', { name: 'Register' }).click();
    await page.getByLabel('Email * 0/').click();
    await page.getByLabel('Email * 0/').fill('a@a.se');
    await page.getByRole('button', { name: 'Send' }).click();
    await expect(page.getByText('You must accept terms of')).toBeVisible();
    await page.getByLabel('Yes').check();
    await page.getByRole('button', { name: 'Send' }).click();
    await expect(page.getByText('Email already exists.')).toBeVisible();

    const randomUSername = Math.random().toString(36).slice(2, 10);
    const randomEmail = `${randomUSername}@flowback.test`;
    await page.getByLabel('Email * 6/').fill(randomEmail);

    let registrationCode = '';
    page.on('response', async (response: any) => {
        if (response.url().includes('register') && !response.url().includes('verify')) {
            registrationCode = await response.text()
        }
    });

    await page.getByRole('button', { name: 'Send' }).click();
    await expect(page.getByText('Email Sent')).toBeVisible();
    await expect(page.getByText('Mail Sent')).toBeVisible();

    await page.getByLabel('Verification Code * 0/').click();
    await page.getByLabel('Verification Code * 0/').fill('geageageadgea');
    await page.getByLabel('Username * 0/').click();
    await page.getByLabel('Username * 0/').fill(randomUSername);
    await page.getByLabel('Choose a Password * 0/').click();
    await page.getByLabel('Choose a Password * 0/').fill('SecretPassword123123!');
    await page.getByRole('button', { name: 'Send' }).click();
    await expect(page.getByText('Wrong verification code')).toBeVisible();
    await page.getByLabel('Verification Code * 13/').click();
    await page.getByLabel('Verification Code * 13/').press('Control+a');
    await page.getByLabel('Verification Code * 13/').fill(registrationCode.replace("\"", "").replace("\"", ""));
    await page.getByRole('button', { name: 'Send' }).click();

    await expect(page.getByText('Success')).toBeVisible();
    await expect(page).toHaveURL('/home?chatOpen=false');

    if (await page.getByRole('button', { name: 'Ok' }).isVisible()) {
        await page.getByRole('button', { name: 'Ok' }).click();
    }
}

export async function logout(page: any) {
    await page.getByRole('button', { name: 'default pfp' }).click();
    await page.getByRole('button', { name: 'Log Out', exact: true }).click();
    await expect(page.getByRole('img', { name: 'flowback logo' })).toBeVisible();
};

