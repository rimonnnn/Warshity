#!/usr/bin/env node
/*
 * One-off backfill: register every existing product barcode in
 * productBarcodeRegistry so the registry is the authoritative global
 * uniqueness source.
 *
 * Why: the client-side legacy collision check can only query the current
 * user's own products (security rules deny unscoped products queries).
 * This Admin-SDK script closes the gap for OTHER users' pre-registry
 * products by creating a registry document for each existing barcode with
 * status 'used', which the app never re-issues (reservations are never
 * deleted and existing registry docs block re-reservation).
 *
 * Safety: runs server-side with full admin privileges (bypasses security
 * rules); no product data is exposed to clients or third parties. Run from
 * a trusted machine only.
 *
 * Usage:
 *   1. npm install firebase-admin   (anywhere; not required in the app)
 *   2. Set GOOGLE_APPLICATION_CREDENTIALS to a service account JSON for
 *      project warshity-75dcf (Firebase console > Project settings >
 *      Service accounts > Generate new private key).
 *   3. node tool/backfill_barcode_registry.js [projectId]
 *
 * Idempotent: existing registry documents are never overwritten.
 */

const admin = require('firebase-admin');

const projectId = process.argv[2] || 'warshity-75dcf';

admin.initializeApp({ projectId });
const db = admin.firestore();

async function main() {
  const productsSnap = await db.collection('products').get();
  console.log(`Scanning ${productsSnap.size} products...`);

  const seenCodes = new Map(); // code -> first product doc id
  let registered = 0;
  let alreadyRegistered = 0;
  let skippedNoBarcode = 0;
  const duplicateConflicts = [];

  for (const doc of productsSnap.docs) {
    const data = doc.data();
    const code = (data.barcode || '').trim();

    if (!code) {
      skippedNoBarcode++;
      continue;
    }

    if (seenCodes.has(code)) {
      duplicateConflicts.push({ code, first: seenCodes.get(code), duplicate: doc.id });
      continue;
    }
    seenCodes.set(code, doc.id);

    const registryRef = db.collection('productBarcodeRegistry').doc(code);
    const existing = await registryRef.get();

    if (existing.exists) {
      alreadyRegistered++;
      continue;
    }

    const userId =
      (typeof data.userId === 'string' && data.userId) ||
      (Array.isArray(data.userIds) && typeof data.userIds[0] === 'string' && data.userIds[0]) ||
      '';

    await registryRef.set({
      code,
      userId,
      status: 'used',
      productId: doc.id,
      usedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    registered++;
    if (registered % 50 === 0) {
      console.log(`  ...registered ${registered}`);
    }
  }

  console.log('Done.');
  console.log(`  registered:          ${registered}`);
  console.log(`  already registered:  ${alreadyRegistered}`);
  console.log(`  skipped (no code):   ${skippedNoBarcode}`);
  console.log(`  duplicate conflicts: ${duplicateConflicts.length}`);
  for (const c of duplicateConflicts) {
    console.log(`    ${c.code}: ${c.first} vs ${c.duplicate}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
