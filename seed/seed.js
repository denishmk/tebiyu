/**
 * Seeds Firestore with the development listings and users.
 *
 * Uses the Admin SDK, which bypasses security rules. That is the point:
 * the rules require a listing's seller_id to match the signed in user, and
 * these sellers have no Auth accounts. Seeding through the client would
 * mean either creating eight real accounts or loosening the rules, and
 * loosening rules for convenience is how databases end up world writable.
 *
 * Written against firebase-admin v14's modular API. Earlier tutorials show
 * `admin.credential.cert(...)` and `admin.firestore()`; v14 moved both into
 * separate submodules, `firebase-admin/app` and `firebase-admin/firestore`.
 *
 * Usage:
 *   node seed.js            insert or overwrite the seed documents
 *   node seed.js --wipe     delete every seeded document first
 *
 * Requires a service account key at ./service-account.json.
 * NEVER commit that file. It grants unrestricted access to the project.
 */

const { initializeApp, cert } = require('firebase-admin/app');
const {
  getFirestore,
  Timestamp,
  FieldValue,
} = require('firebase-admin/firestore');
const { listings, users, counters } = require('./data');

const serviceAccount = require('./service-account.json');

initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();
const wipe = process.argv.includes('--wipe');

/** Converts the ISO date strings in the seed data to Firestore Timestamps. */
function withTimestamps(record, keys) {
  const out = { ...record };
  for (const key of keys) {
    if (out[key]) out[key] = Timestamp.fromDate(new Date(out[key]));
  }
  return out;
}

async function deleteCollection(name) {
  const snapshot = await db.collection(name).get();
  if (snapshot.empty) return 0;

  // Batches cap at 500 writes, so a large collection is chunked. The seed
  // set is far smaller than that, but a wipe run against a database that
  // has grown should not silently truncate.
  let deleted = 0;
  for (let i = 0; i < snapshot.docs.length; i += 450) {
    const batch = db.batch();
    for (const doc of snapshot.docs.slice(i, i + 450)) batch.delete(doc.ref);
    await batch.commit();
    deleted += Math.min(450, snapshot.docs.length - i);
  }
  return deleted;
}

async function main() {
  if (wipe) {
    const removedListings = await deleteCollection('listings');
    const removedUsers = await deleteCollection('users');
    console.log(`Wiped ${removedListings} listings and ${removedUsers} users.`);
  }

  const batch = db.batch();

  for (const user of users) {
    const { id, ...rest } = user;
    batch.set(
      db.collection('users').doc(id),
      withTimestamps(rest, ['member_since']),
    );
  }

  for (const listing of listings) {
    const { id, ...rest } = listing;
    batch.set(
      db.collection('listings').doc(id),
      withTimestamps(rest, ['created_at', 'expires_at', 'promoted_until']),
    );
  }

  // Subcategory counts live in one document because a hundred aggregation
  // queries per screen open is not viable. A Cloud Function keeps this in
  // step once listings are created through the app.
  batch.set(db.doc('counters/subcategories'), counters);

  batch.set(db.doc('config/exchange_rate'), {
    ssp_per_usd: 7500,
    updated_at: Timestamp.now(),
  });

  await batch.commit();

  console.log(`Seeded ${users.length} users and ${listings.length} listings.`);
  console.log('Exchange rate set to 7500 SSP per USD.');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Seed failed:', error.message);
    process.exit(1);
  });
  