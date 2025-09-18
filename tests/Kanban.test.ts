import { test, expect } from '@playwright/test';
import { login } from './generic';
import { gotoGroup } from './group';

test('Kanban-User', async ({ page }) => {
  await login(page);

  // Navigate to the kanban page
  await page.goto('/kanban');
  await expect(page).toHaveURL('/kanban?chatOpen=false');

  // Check if the kanban board is visible
  const kanbanBoard = await page.locator('#kanban-board');
  await expect(kanbanBoard).toBeVisible();

  const doneButton = await page.locator('#Done-add');
  await expect(doneButton).toBeVisible();
  await page.waitForTimeout(400);
  await doneButton.click();

  const createModal = await page.locator('#create-kanban-entry-modal');
  await expect(createModal).toBeVisible();
  await page.locator('#create-kanban-text').fill('test kanban');
  await page.locator('#create-kanban-textarea').fill('test kanban description');

  await page.locator('button', {hasText:"Confirm"}).click()
  await expect(createModal).toBeHidden();
});

test('Kanban-Group', async ({ page }) => {
  await login(page);

  await gotoGroup(page);

  await page.locator('#group-tasks-sidebar-button').click();

  // await expect(page).toHaveURL('/kanban?groupId=?chatOpen=false');

  // Check if the kanban board is visible
  const kanbanBoard = await page.locator('#kanban-board');
  await expect(kanbanBoard).toBeVisible();

  const doneButton = await page.locator('#Done-add');
  await expect(doneButton).toBeVisible();

  doneButton.click();
  const createModal = await page.locator('#create-kanban-entry-modal');
  await expect(createModal).toBeVisible();

  await page.locator('#create-kanban-text').fill('test kanban');
  await page.locator('#create-kanban-textarea').fill('test kanban description');

  await page.locator('button', {hasText:"Confirm"}).click()
  await expect(createModal).toBeHidden();
});


test('Kanban-Edit', async ({ page }) => {
  await login(page);


  // Navigate to the kanban page
  await page.goto('/kanban');
  await expect(page).toHaveURL('/kanban?chatOpen=false');

  // Check if the kanban board is visible
  const kanbanBoard = await page.locator('#kanban-board');
  await expect(kanbanBoard).toBeVisible();

  //n-th member of done-kanban-lane
  const doneLane = await page.locator('#Done-kanban-lane');
  await page.waitForTimeout(1000);

  const kanbanEntry = page.locator('#Done-kanban-lane > ul > div').first();
  await expect(kanbanEntry).toBeVisible();

  await kanbanEntry.click();
  await page.waitForTimeout(300);

  const kanbanEntryModal = await page.locator('#kanban-entry-modal');
  await expect(kanbanEntryModal).toBeVisible();

  const editButton = await page.locator('#Edit');

  editButton.click();
  await page.waitForTimeout(300);

  await page.locator('#kanban-edit-title').fill('test kanban edited');
  await page.locator('#kanban-edit-description').fill('test kanban description edited');

  // Add response listener before clicking update
  const responsePromise = page.waitForResponse(response =>
    response.url().includes('/user/kanban/entry/update') && response.status() === 200
  );

  await page.click('#Update');
  await responsePromise; // Wait for successful response

  await page.click('#Close');
  await expect(kanbanEntryModal).toBeHidden();
});

test('Kanban-Delete', async ({ page }) => {
  await login(page);


  // Navigate to the kanban page
  await page.goto('/kanban');
  await expect(page).toHaveURL('/kanban?chatOpen=false');

  // Check if the kanban board is visible
  const kanbanBoard = await page.locator('#kanban-board');
  await expect(kanbanBoard).toBeVisible();

  //n-th member of done-kanban-lane
  const doneLane = await page.locator('#Done-kanban-lane');
  await page.waitForTimeout(1000);

  const kanbanEntry = page.locator('#Done-kanban-lane > ul > div').first();
  await expect(kanbanEntry).toBeVisible();

  await kanbanEntry.click();
  await page.waitForTimeout(300);

  const editButton = await page.locator('#Edit');
  editButton.click();
  const kanbanEntryModal = await page.locator('#kanban-entry-modal');
  await expect(kanbanEntryModal).toBeVisible();

  const deleteButton = await page.locator('#Delete');
  await expect(deleteButton).toBeVisible();

  await deleteButton.click();
  await expect(kanbanEntryModal).toBeHidden();
});