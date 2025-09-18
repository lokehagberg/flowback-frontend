import { expect } from '@playwright/test';

export async function fastForward(page: any, times = 1) {
    await expect(page.locator('#poll-header-multiple-choices')).toBeVisible();
    await page.locator('#poll-header-multiple-choices').getByRole('button').click();
    for (let i = 0; i < times; i++) {
        await page.waitForTimeout(300);
        await page.getByRole('button', { name: 'Fast Forward' }).click();
    }
}

export async function createPoll(page: any, {
    title = 'Test Poll', date = false, phase_time = 0 } = {}) {
    //Create a Poll
    await page.getByRole('button', { name: 'Create a post' }).click();
    await expect(page.getByText('PollThread')).toBeVisible();
    await page.getByLabel('Title * 0/').click();
    await page.getByLabel('Title * 0/').fill(title);
    await page.getByLabel('Description  0/').fill('Test Description');

    if (date) await page.getByLabel('Date Poll').check();

    await page.getByRole('button', { name: 'Display advanced time settings' }).click();
    await page.locator('fieldset').filter({ hasText: 'Public? Yes No' }).getByLabel('Yes').check();
    await page.locator('fieldset').filter({ hasText: 'Fast Forward? Yes No' }).getByLabel('Yes').check();
    await page.getByRole('spinbutton').fill(phase_time.toString());

    await page.getByRole('button', { name: 'Post' }).click();
    await page.waitForTimeout(500);
    await expect(page.getByRole('heading', { name: title })).toBeVisible();
}

export async function goToPost(page: any, {
    title = 'Test Poll'
}) {
    await page.getByRole('link', { name: 'Home' }).click();
    await page.getByPlaceholder('Search polls').click();
    await page.getByPlaceholder('Search polls').fill(title);
    await expect(page.locator('#thumbnails > div').getByRole('link', { name: title, exact: true }).first()).toBeVisible();
    await page.locator('#thumbnails > div').getByRole('link', { name: title, exact: true }).first().click();
    await expect(page.getByRole('heading', { name: title })).toBeVisible();

    // await expect(page.locator('#poll-thumbnail-140').getByRole('link', { name: 'Test Poll' })).toBeVisible();
}

export async function areaVote(page: any, {
    area = 'Default',
} = {}) {
    await page.getByRole('radio').nth(0).check();
    await page.getByRole('button', { name: 'Submit' }).click();
    await page.waitForTimeout(100)
    await expect(page.getByText('Successfully voted for area')).toBeVisible();
    await page.getByRole('button', { name: 'Cancel' }).click();
    await expect(page.getByText('Vote cancelled')).toBeVisible();
    await page.getByRole('radio').nth(1).check();
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Successfully voted for area')).toBeVisible();
}

export async function createProposal(page: any, {
    title = 'Test Proposal',
    description = 'Test Description',
} = {}) {
    //Proposal phase
    await page.getByRole('button', { name: 'Add Proposal' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).fill(title);
    await page.getByLabel('Description  0/').click();
    await page.getByLabel('Description  0/').fill(title);
    await page.getByRole('button', { name: 'Cancel' }).click();
    await page.getByRole('button', { name: 'Add Proposal' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).fill('description');
    await page.getByText('Description 0/').click();
    await page.getByLabel('Description  0/').click();
    await page.getByLabel('Description  0/').fill('description');
    await page.getByRole('button', { name: 'Confirm' }).click();
    await expect(page.getByText('Successfully added proposal')).toBeVisible();
    // await page.getByRole('button', { name: 'Add Proposal' }).click();

    await page.getByRole('textbox', { name: 'Title * 0/' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).fill('Proposal Test 3');
    await page.getByText('Description 0/').click();
    await page.getByLabel('Description  0/').click();
    await page.getByLabel('Description  0/').fill('Proposal Test 3');
    await page.getByRole('button', { name: 'Confirm' }).click();
    await expect(page.getByText('Successfully added proposal')).toBeVisible();
    // await page.getByRole('button', { name: 'Proposal Test 3 Proposal Test' }).click();
}

export async function predictionStatementCreate(page: any) {
    // Prediction Statement Phase
    await page.waitForTimeout(600);
    await page.getByRole('button', { name: 'See More' }).nth(1).click();
    await page.getByRole('button', { name: 'See More' }).nth(0).click();

    await page.locator('.border-b-2 > .dark\\:bg-darkobject > div > button').nth(0).click();
    await page.locator('.mt-4 > div:nth-child(2) > .dark\\:bg-darkobject > div > button').nth(0).click();

    await page.getByRole('button', { name: 'Create Consequence' }).nth(0).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).fill('Prediction 1');
    await page.getByLabel('Description  0/').click();
    await page.getByLabel('Description  0/').fill('Prediction 1');
    // await page.getByPlaceholder('-08-27 14:40:00').click();
    await page.locator('.date-time-field > input').nth(0).fill('2025-08-27 15:40:00');
    // await page.locator('div').filter({ hasText: /^18$/ }).click();
    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Successfully created')).toBeVisible();
}

export async function predictionProbability(page: any) {
    //Prediction Betting
    await page.locator('div').filter({ hasText: 'Current: Phase 4. Consequence' }).nth(2).click();
    await page.locator('div').filter({ hasText: 'See More' }).nth(0).click();

    await page.getByRole('button', { name: 'See More' }).nth(1).click();
    await page.waitForTimeout(300);
    await page.locator('#track-container > div:nth-child(3)').click();
    await page.waitForTimeout(300);
    await expect(page.getByText('Probability successfully sent')).toBeVisible();
    await page.locator('#track-container > div:nth-child(5)').click();
    await page.waitForTimeout(300);
    await page.getByRole('button', { name: 'See More' }).nth(0).click();
    await expect(page.locator('#track-container')).toBeVisible();
    await page.waitForTimeout(300);
    
    await page.locator('#track-container > div').nth(5).click();
    await expect(page.getByText('Probability successfully sent').nth(0)).toBeVisible();
    await page.waitForTimeout(300);
    await page.getByRole('button', { name: 'See More' }).nth(1).click();
    await page.waitForTimeout(300);
    // await expect(page.locator('#track-container > div:nth-child(8)')).toBeVisible();
    // await page.waitForTimeout(200);
    // await page.locator('#track-container > div:nth-child(6)').click();
    await page.locator('#track-container > div:nth-child(5)').click();
    await page.waitForTimeout(300);
    await page.getByRole('button', { name: 'Clear probability' }).click();
    await page.locator('#track-container > div:nth-child(4)').click();
    await page.waitForTimeout(300);
    await expect(page.getByText('Probability successfully sent').nth(0)).toBeVisible();

}

export async function delegateVote(page: any) {
    // Delegate Voting Phase
    await page.locator('div').filter({ hasText: 'Current: Phase 5. Delegate' }).nth(2).click();
    await page.getByRole('button', { name: 'See more' }).nth(0).click();
    await page.getByText('Successfully voted').isVisible();


    await page.locator('#track-container > div:nth-child(4)').first().click();
    await page.locator('div:nth-child(2) > div > div:nth-child(3) > #track-container > div:nth-child(6)').click();

    await page.getByRole('button', { name: 'See More' }).nth(0).click();
    // await expect(page.getByText('Probability: 80%')).toBeVisible();
    await page.getByRole('button', { name: 'See More' }).nth(1).click();
    // await expect(page.getByText('Probability: 40%')).toBeVisible();
}

export async function vote(page: any) {
    // Delegate Voting Phase
    await expect(page.locator('div').filter({ hasText: 'Phase 6. Voting for non-delegates' }).nth(2)).toBeVisible();
    await page.getByRole('button', { name: 'See more' }).nth(0).click();
    await page.getByText('Successfully voted').isVisible();


    await page.locator('#track-container > div:nth-child(4)').first().click();
    await page.locator('div:nth-child(2) > div > div:nth-child(3) > #track-container > div:nth-child(6)').click();

    await page.getByRole('button', { name: 'See More' }).nth(0).click();
    // await expect(page.getByText('Probability: 80%')).toBeVisible();
    await page.getByRole('button', { name: 'See More' }).nth(1).click();
    // await expect(page.getByText('Probability: 40%')).toBeVisible();

    // await page.locator("#proposals-section").screenshot({ path: 'tests/voting.png', fullPage: true });
    // await expect(page.locator("#proposals-section")).toHaveScreenshot('tests/voting.png');

    // await page.reload();
    // await page.waitForLoadState('networkidle');

    // await expect(page.locator("#proposals-section")).toHaveScreenshot('tests/voting.png');

}

export async function results(page: any) {
    await expect(page.getByText('Results', { exact: true })).toBeVisible();

    await expect(page.locator('canvas')).toBeVisible();

    await page.locator('canvas').click({
        position: {
            x: 43,
            y: 92
        }
    });
    await expect(page.getByText('Current: Phase 7. Results and')).toBeVisible();
}