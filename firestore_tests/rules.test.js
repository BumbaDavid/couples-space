const { initializeTestEnvironment, assertSucceeds, assertFails } =
  require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

let env;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'couples-notes-test',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

afterEach(async () => {
  await env.clearFirestore();
});

afterAll(async () => {
  await env.cleanup();
});

function asUser(uid) {
  return env.authenticatedContext(uid).firestore();
}

async function seedCouple() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc('users/A').set({ email: 'a@x', displayName: 'A', coupleId: 'C1' });
    await db.doc('users/B').set({ email: 'b@x', displayName: 'B', coupleId: 'C1' });
    await db.doc('users/X').set({ email: 'x@x', displayName: 'X' });
    await db.doc('couples/C1').set({ memberIds: ['A', 'B'] });
    await db.doc('couples/C1/sharedNotes/n1').set({ title: 't', body: 'b', authorId: 'A' });
    await db.doc('users/A/privateNotes/p1').set({ title: 't', body: 'b', authorId: 'A' });
  });
}

describe('users collection', () => {
  test('self can read own user doc', async () => {
    await seedCouple();
    await assertSucceeds(asUser('A').doc('users/A').get());
  });
  test('partner can read paired user doc', async () => {
    await seedCouple();
    await assertSucceeds(asUser('B').doc('users/A').get());
  });
  test('outsider cannot read user doc', async () => {
    await seedCouple();
    await assertFails(asUser('X').doc('users/A').get());
  });
  test('only self can update', async () => {
    await seedCouple();
    await assertSucceeds(asUser('A').doc('users/A').update({ displayName: 'AA' }));
    await assertFails(asUser('B').doc('users/A').update({ displayName: 'NOPE' }));
  });
});

describe('couples and sharedNotes', () => {
  test('member can read couple', async () => {
    await seedCouple();
    await assertSucceeds(asUser('A').doc('couples/C1').get());
  });
  test('non-member cannot read couple', async () => {
    await seedCouple();
    await assertFails(asUser('X').doc('couples/C1').get());
  });
  test('member can read shared note', async () => {
    await seedCouple();
    await assertSucceeds(asUser('B').doc('couples/C1/sharedNotes/n1').get());
  });
  test('non-member cannot read shared note', async () => {
    await seedCouple();
    await assertFails(asUser('X').doc('couples/C1/sharedNotes/n1').get());
  });
});

describe('private notes', () => {
  test('owner can read own private note', async () => {
    await seedCouple();
    await assertSucceeds(asUser('A').doc('users/A/privateNotes/p1').get());
  });
  test("partner cannot read other's private note", async () => {
    await seedCouple();
    await assertFails(asUser('B').doc('users/A/privateNotes/p1').get());
  });
});

describe('invite codes', () => {
  test('signed-in user can read an invite', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc('inviteCodes/ABC234').set({ createdBy: 'A' });
    });
    await assertSucceeds(asUser('B').doc('inviteCodes/ABC234').get());
  });
  test("creating an invite with someone else's uid is denied", async () => {
    await assertFails(
      asUser('B').doc('inviteCodes/XYZ234').set({ createdBy: 'A' }),
    );
  });
});
