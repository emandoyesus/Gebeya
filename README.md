# Gebeya

Flutter market price tracker for Ethiopia.

## Run

```sh
flutter pub get
flutter run
```

## Marketplace categories

26 shopping categories cover food, electronics, clothes, footwear, bags,
beauty, health supplies, baby products, furniture, kitchenware, appliances,
cleaning, books, sports, toys, automotive supplies, tools, gardening and pets.
Use **Browse all** to search categories and see their catalog counts.
Choosing a category clears the old search query. The catalog has distinct
loading/error states and a clear-filters action for genuine empty searches.

`assets/data/marketplace_catalog.json` adds 160 bilingual catalog entries
without made-up prices or availability. Pack sizes and units are included.
Existing sourced offers and demo groceries remain available.
The app reads the checked-in `lib/core/constants/bundled_catalog.dart` snapshot
so a missing/stale asset manifest cannot hide the catalog. Keep it synchronized
with both catalog JSON files; the catalog test checks this. Product-type
entries are starting points, not evidence that a particular seller stocks them.

For an existing Supabase database, apply `supabase_expand_categories.sql`,
commit it, then apply `supabase_seed_marketplace.sql`. New databases can use the
updated `supabase_schema.sql` followed by the seed. Stable IDs make the seed
safe to rerun. These SQL files have not been applied to a live database.

## Public listing snapshots

The app bundles 21 additional public listings in
`assets/data/public_listings.json`: 14 web listings and 7 Telegram listings.
Collected on 2026-11-16 from Davi Technology, public @AddisMobile and
@ethicomputer posts, and Jiji clothing listings.

Each record contains a stable UUID, model/variant, ETB asking price, source URL,
collection date, and source limitations. Seller claims are not independently
verified. Collection date is not publication date. No private chats, phone
numbers, or personal profiles are imported.

These are saved snapshots, not a continuously running scraper. Pull-to-refresh
reloads the catalog and backend; it does not re-scrape websites. Existing
category pictures are illustrative, not product photos extracted from sellers.
All categories have image URLs, including 17 newly sourced Pexels photographs.
See `IMAGE_CREDITS.md` for their original pages. Images require internet access;
category icons are shown while loading or offline. Flutter web can fall back
to HTML image rendering when an image host blocks cross-origin decoding.

Listings work offline and remain visible alongside backend items. Backend
records with the same UUID take precedence. Two sellers offering the same model
remain separate offers. Listings without a clear price/model and wholesale-only
quotes were excluded. No reports or market medians are fabricated from these
offers.

## Supabase import

For an existing database, apply `supabase_add_catalog_categories.sql` and commit
it first. Then apply `supabase_import_public_listings.sql`. For a new database,
apply `supabase_schema.sql` before the import.

The import adds listing metadata columns and inserts records with stable UUIDs.
It is safe to rerun: existing IDs are not overwritten. The app does not permit
remote price reports against bundled-only listings until their UUIDs exist in
the backend. The SQL has not been applied to a live database by this change.

To refresh the snapshot, review the original public source, update the price
and collection date, preserve each offer's UUID, and explicitly update its
backend row if needed. Never infer missing RAM/storage, condition, stock,
publication dates, or prices from unrelated offers.
