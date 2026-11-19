# Tebiyu Firestore seed

Pushes the development listings, users, subcategory counters and exchange
rate into Firestore.

## Why the Admin SDK

The security rules require a listing's `seller_id` to match the signed in
user. These eight sellers have no Auth accounts, so seeding through the
client SDK would mean either creating eight real accounts or loosening the
rules. Loosening rules for convenience is how databases end up world
writable, so this uses the Admin SDK, which bypasses rules by design.

## Setup

1. Firebase Console → Project settings → **Service accounts** →
   **Generate new private key**. Save the download as
   `seed/service-account.json`.

   That file grants unrestricted access to the entire project. It is in
   `.gitignore` and must stay out of the repository. If it ever leaks,
   revoke the key from the same console page immediately.

2. Install dependencies:

       cd seed
       npm install

## Running

    npm run seed      # insert or overwrite the seed documents
    npm run reseed    # delete every listing and user first, then seed

Document ids are fixed (`lst_001`, `usr_101`), so re-running overwrites
rather than duplicating. Use `reseed` only when you want documents created
through the app removed too.

## Regenerating data.js

`data.js` is generated from the Dart mock repositories so the two cannot
drift. Edit `mock_listing_repository.dart` or `mock_user_repository.dart`,
then regenerate rather than editing `data.js` by hand.

## After seeding

Point the app at Firestore by changing two providers:

- `listingRepositoryProvider` → `FirestoreListingRepository`
- `userRepositoryProvider` → `FirestoreUserRepository`

Expect missing index errors on the first filtered queries. Each error
carries a console link that creates the exact index needed. Once the app
runs cleanly, pull them into version control:

    firebase firestore:indexes > firestore.indexes.json
