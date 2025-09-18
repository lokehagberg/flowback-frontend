import { test, expect } from '@playwright/test';
import { areaVote, createPoll, createProposal, delegateVote, fastForward, goToPost, predictionProbability, predictionStatementCreate, results, vote } from './poll';
import { login } from './generic';
import { gotoGroup, createArea, createGroup, deleteGroup } from './group';

test('Go-To-Post', async ({ page }) => {
    await login(page);

    const group = { name: "Test Group Poll", public: false }
    await gotoGroup(page, group)

    //Random poll name
    const pollTitle = `Test Poll ${Math.floor(Math.random() * 10000)}`;
    const poll = { title: pollTitle, date: false }
    await createPoll(page, poll);
    await goToPost(page, poll);
})


test('Poll-Start-To-Finish', async ({ page }) => {
    await login(page);

    let group = { name: "Test Group Poll", public: false }

    try {
        await gotoGroup(page, group)
    }
    catch {
        await createGroup(page, group)
    }

    await createArea(page, group, "Tag 1")

    await createArea(page, group, "Tag 2")

    await gotoGroup(page, group);

    await createPoll(page, { phase_time: 1 });

    await areaVote(page);

    await fastForward(page, 1);

    await createProposal(page);

    await fastForward(page, 1);

    await predictionStatementCreate(page);

    await fastForward(page, 1);

    // await predictionProbability(page);

    // await fastForward(page, 2);

    // await vote(page);

    // await fastForward(page, 1);

    // await results(page);

});

test('Date-Poll', async ({ page }) => {
    await login(page);

    const group = { name: "Test Group Poll", public: false }
    const poll = { title: "Test Group Poll", date: true }

    try {
        await createGroup(page, group)
    }
    catch {
        await gotoGroup(page, group)
    }

    await gotoGroup(page, group);

    await createPoll(page, poll);

    await page.locator('button:nth-child(45)').click();
    await page.locator('button:nth-child(46)').click();
    await page.locator('button:nth-child(55)').click();
    await page.locator('button:nth-child(64)').click();
    await page.getByRole('button', { name: 'Submit' }).click();

    await fastForward(page, 1);

    await expect(page.getByText('Results', { exact: true })).toBeVisible();
});

test('Thread-Create-Report-Delete', async ({ page }) => {

    await login(page);

    let group = { name: "Test Group Thread", public: false }

    await createGroup(page, group)

    await gotoGroup(page, group);

    await page.getByRole('button', { name: 'Create a post' }).click();
    await page.getByText('Poll Thread Poll Content Text')
    await page.getByRole('button', { name: 'Thread' }).click();

    await page.getByLabel('Title * 0/').click();
    await page.getByLabel('Title * 0/').fill('Test Thread');
    await page.getByLabel('Description  0/').click();
    await page.getByLabel('Description  0/').fill('Test Description');

    await page.getByRole('button', { name: 'Post' }).click();
    await expect(page.getByRole('heading', { name: 'Thread' })).toBeVisible();
    await page.getByPlaceholder('Write a comment...').click();
    await page.getByPlaceholder('Write a comment...').fill('Test Comment');
    await page.locator('#comments').getByRole('button').nth(1).click();
    await page.locator('div:nth-child(4) > div > button:nth-child(2)').click();
    await page.locator('div:nth-child(4) > div > button').first().click();
    await page.getByRole('button', { name: 'Reply' }).click();
    await page.getByPlaceholder('Write a comment...').nth(1).click();
    await page.getByPlaceholder('Write a comment...').nth(1).fill('Test Reply with file');
    await page.locator('.flex > form > div:nth-child(2) > div:nth-child(2) > .content-center > div > input').setInputFiles('./tests/forward-facing-niko-oneshot-isnt-real-it-cant-hurt-you-v0-3ggf23q4ijcf1.webp');
    await page.locator('form').filter({ hasText: 'forward-facing-niko-oneshot-' }).getByRole('button').nth(2).click();
    await expect(page.getByRole('img', { name: 'Attachment to the comment' })).toBeVisible();
    await page.locator('#multiple-choices').getByRole('button').click();
    await page.getByRole('button', { name: 'Report Thread' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).click();
    await page.getByRole('textbox', { name: 'Title * 0/' }).fill('Report Test');
    await page.locator("#report-description").click();
    await page.locator("#report-description").fill('This is a test report');
    await page.getByRole('button', { name: 'Report', exact: true }).click();
    await page.getByRole('button', { name: 'Delete Thread' }).click();
    await page.getByRole('button', { name: 'Cancel', exact: true }).click();
    await page.getByRole('button', { name: 'Delete Thread' }).click();
    await page.getByRole('button', { name: 'Remove', exact: true }).click();
    await expect(page.getByText('Successfully deleted thread')).toBeVisible();

    await deleteGroup(page, group);
});