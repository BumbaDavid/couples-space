# Protein Tracker — engineering design

**Date:** 2026-08-08
**Status:** Approved, ready for implementation planning
**Feature:** 6th bottom-nav tab tracking daily protein intake

## Source documents

This spec is the *engineering* counterpart to three existing documents. It does not
restate them; read them for anything not covered here.

| Document | Authority over |
|---|---|
| [`docs/design/protein_tracker_export/README.md`](../../design/protein_tracker_export/README.md) | Screens, layout, exact px/colour/weight, copy, interactions. **High fidelity — treat as final.** |
| `docs/design/protein_tracker_export/Protein Tracker.dc.html` | Interactive prototype of all six screens |
| [`docs/vault/ideas/protein-tracker-feature.md`](../../vault/ideas/protein-tracker-feature.md) | Why the feature is shaped this way; the authoritative record of product decisions |

Where the design README and the vault note disagree, the vault note wins on **data
model and persistence** (the README says only "local, per the codebase's existing
storage" — it was written without backend knowledge); the README wins on **everything
visual and interactive**.

## Non-negotiable content rules

The intended user has a history of disordered eating. These are hard constraints — a
reviewer should reject any violation:

- **Never** show calories, BMI, weight, weight-loss projections, or any comparison
  between the two partners.
- **Never** use the words *failed*, *missed*, *over*, *under*, or *remaining* in any
  user-visible string.
- **Never** use red or any error/warning colour for a protein state.
  `AppColors.failText` / `failBg` **must not appear anywhere in this feature.**
- **No streaks.** **No pass/fail on a day** — no "goal met" tick, badge, or celebration.
- Show what exists, not what is absent: *"You've logged 60g today"*, never *"40g to go"*.
- 0g and above-target are both deliberately unremarkable — nothing scolds, nothing
  celebrates.
- The weekly average must **never** render without its day count.

## Scope

**In:** food card catalog (shared, CRUD), one-tap logging with slot selection and undo,
repeat-tap stacking, day navigation backwards, per-user editable target, weekly average
and 7-day chart, entry editing, empty states.

**Out** (do not build): calories/carbs/fats/TDEE/weight/BMI, barcode scanning, food
search or nutrition database, notifications (the Reminders feature owns those), sharing
protein data between partners, onboarding or first-run wizards.

## Data model

### Firestore paths

| Collection | Path | Access |
|---|---|---|
| Food catalog | `couples/{coupleId}/foods/{foodId}` | Both partners — shared knowledge |
| Protein log | `users/{userId}/proteinLog/{entryId}` | **Strictly private to the owner** |
| Daily target | `users/{userId}.proteinTargetGrams` | Field on the existing user doc |

The catalog is the project's second couple-scoped collection after `sharedNotes`. The
log follows the same shape as workout data.

### Models (freezed + json_serializable, per project convention)

```dart
// data/food_card.dart
@freezed
abstract class FoodCard with _$FoodCard {
  const factory FoodCard({
    required String id,
    required String name,
    required int proteinGrams,   // per serving, 1..120
    required String icon,        // key into ProteinIcons.byName
    required DateTime createdAt, // catalog ordering → drives tile colour index
  }) = _FoodCard;
  factory FoodCard.fromJson(Map<String, dynamic> json) => _$FoodCardFromJson(json);
}
```

```dart
// data/protein_entry.dart
@freezed
abstract class ProteinEntry with _$ProteinEntry {
  const factory ProteinEntry({
    required String id,
    required String day,        // 'yyyy-MM-dd' — see Decision 1
    required String cardId,
    required String name,       // snapshotted at log time
    required String icon,       // snapshotted at log time
    required int unit,          // grams per serving, 1..200
    @Default(1) int count,      // ≥ 1
    required ProteinSlot slot,
  }) = _ProteinEntry;
  factory ProteinEntry.fromJson(Map<String, dynamic> json) =>
      _$ProteinEntryFromJson(json);
}

extension ProteinEntryX on ProteinEntry {
  int get total => unit * count;
}
```

`name` and `icon` are **snapshotted onto the entry**. Renaming, re-icon-ing, or deleting
a food card must never rewrite history or change a past weekly average. This is a hard
invariant from the vault note.

```dart
// data/protein_slot.dart
enum ProteinSlot { morning, noon, afternoon, evening, night }
```

Clock → slot mapping (design README): `<11:00` morning · `<14:00` noon · `<17:00`
afternoon · `<21:00` evening · else night. Display order is always this enum order;
`afternoon` abbreviates to `Aft.` **only** in the 5-column selector grid, full word
everywhere else.

### UserProfile change

Add to the existing freezed model, then re-run `build_runner`:

```dart
@Default(110) int proteinTargetGrams,
```

`@Default` makes existing user documents that lack the field decode as 110 — backward
compatible, no migration. Range 20–300, stepped by 1. (The design README says step 5;
changed on request 2026-08-09, along with making every stepper's number tappable so a
distant value can be typed rather than stepped to.)

### Icons — two design names do not exist in Flutter

`protein_icons.dart` maps stored string keys → `IconData`, mirroring
`WorkoutIcons.forBodyPart`. The stored key is a string so the catalog is not coupled to
Flutter's icon codepoints.

We stay on Flutter's **built-in `Icons`** and do *not* add `material_symbols_icons` — the
vault note is explicit that "Material's built-in food icons suffice — no new dependency",
and post-V1 scope says no speculative dependencies.

The design README names icons from Material **Symbols**. All were checked against
`packages/flutter/lib/src/material/icons.dart` in the pinned SDK; **two have no `Icons`
equivalent** and are substituted:

| Design README | Exists in `Icons`? | Use instead |
|---|---|---|
| `nutrition` (nav tab) | ✗ | **`Icons.restaurant_menu`** |
| `grocery` (20th food icon) | ✗ | **`Icons.local_grocery_store`** |

The other 28 names the design specifies — the 18 remaining food icons, the five slot
icons, and `local_florist`, `insights`, `bookmark_border`, `backspace`, `check_circle`,
`flag` — all verified present. Do not silently swap any of those; they are correct.

## Decision 1 — `day` stored as a `yyyy-MM-dd` string

Every query in this feature is day- or week-bucketed, so day identity is the core
correctness property.

- **Day query:** exact string equality — `where('day', isEqualTo: '2026-08-08')`.
- **Week query:** lexicographic range — `where('day', isGreaterThanOrEqualTo: monday)`
  `.where('day', isLessThanOrEqualTo: sunday)`. ISO-8601 dates sort correctly as strings.

**Rejected:** `Timestamp` at local midnight, which is what `WorkoutRepository` uses for
its `date` field. It would be more consistent with the existing code, but day identity
would then depend on constructing local midnight correctly, and a DST shift can push an
entry into the neighbouring day. A workout landing on the wrong side of midnight is
cosmetic; a protein entry doing it corrupts both the ring and the weekly average.

This is a **deliberate divergence** from the workout convention. `protein_date_utils.dart`
owns all conversion (`DateTime → 'yyyy-MM-dd'`, week start/end, day arithmetic) so the
format lives in exactly one place.

## Decision 2 — stacking via query-for-match on write

Tapping the same card repeatedly merges into one row rather than creating duplicates.

**Merge key:** `day` + `slot` + `cardId` + `unit` all equal. Otherwise, create a new row.

**Write path for `logCard`:**
1. Find an entry matching all four fields **in the caller's already-streamed
   day list**, which is passed in as `dayEntries`.
2. If found → `update({'count': FieldValue.increment(1)})`.
3. If not → create with `uuid.v4()` and `count: 1`.

> **Revised 2026-08-09.** This originally issued a Firestore query to find the
> merge candidate. That `get()` blocked on a network round-trip *before* any
> write happened, so a card tap visibly lagged before its row appeared. Writes
> alone hit the local cache immediately and surface through the snapshot
> listener at once, so the lookup was moved in-memory. The screen already holds
> the day's entries because it is displaying them, so this costs nothing and
> also avoids needing a composite index for the four-equality query.

**Rejected:** deterministic document IDs (`{day}_{slot}_{cardId}_{unit}`), which would
make merging atomic with a single `set(merge: true)` + `increment(1)` and no prior read.
It breaks as soon as S4 edits an entry's amount: the ID still encodes the old unit, so a
later tap of the original card merges into a document whose content no longer matches.
Recoverable only by delete-and-recreate, which negates the simplicity.

The read-then-write race is acceptable — the log is per-user and single-device in
practice.

**Consequences to honour in the UI:**
- Merged rows show a `×n` pill and sub-line `"{Slot} · {unit}g each"`; the right-hand
  figure is `unit × count`.
- The row's trailing button **decrements**: icon `remove` while `count > 1`, switching to
  `backspace` at `count == 1`, where it deletes the row.
- Undo steps a merged count back down rather than deleting the whole stacked row.
- An entry whose `unit` was edited in S4 no longer matches the card's stored value, so it
  correctly stays a separate row.

## Repository API

One `ProteinRepository` per project convention (the workout feature likewise wraps three
collections in one repository). It binds `userId` in the constructor like
`WorkoutRepository`, and takes `coupleId` per-method like `SharedNotesRepository`,
because `coupleId` is nullable until pairing completes.

```dart
class ProteinRepository {
  ProteinRepository({required FirebaseFirestore db, required String userId});

  // Catalog (couple-scoped)
  Stream<List<FoodCard>> watchFoods(String coupleId);            // orderBy createdAt
  Future<void> createFood(String coupleId, {required String name, required int grams, required String icon});
  Future<void> updateFood(String coupleId, FoodCard card);
  Future<void> deleteFood(String coupleId, String foodId);       // does NOT touch past entries

  // Log (user-scoped, private)
  Stream<List<ProteinEntry>> watchDay(String day);
  Stream<List<ProteinEntry>> watchWeek(String startDay, String endDay);
  Future<String> logCard(FoodCard card, {required String day, required ProteinSlot slot, required List<ProteinEntry> dayEntries});
  Future<void> updateEntry(ProteinEntry entry);
  Future<void> decrementEntry(ProteinEntry entry);               // count-1, or delete at 1
  Future<void> deleteEntry(String entryId);

  // Target
  Future<void> setTarget(int grams);                             // users/{uid}.proteinTargetGrams
}
```

Deleting a food card intentionally leaves historical entries untouched — they carry their
own snapshotted `name`/`icon`.

Errors: repository throws typed exceptions; screens convert to user-visible messages at
the screen boundary (project convention). Error copy must obey the content rules above.

## Providers

`providers/protein_providers.dart`, following `workout_providers.dart`:

- `proteinRepositoryProvider` — needs auth uid, throws `StateError` if unauthenticated.
- `foodCardsProvider` — `StreamProvider<List<FoodCard>>`, watches the couple's catalog.
- `dayEntriesProvider` — `StreamProvider.family<List<ProteinEntry>, String>` keyed by day.
- `weekEntriesProvider` — `StreamProvider.family` keyed by a week-range params class with
  proper `==`/`hashCode` (see `WeeklyEntriesParams`).
- `weeklyProteinStatsProvider` — derived sync `Provider.family` returning
  `{averageGrams, daysLogged, List<DayTotal> days, weekTotal}`.
- `proteinTargetProvider` — reads `proteinTargetGrams` off the existing user profile stream.
- View state (`dayOffset ≤ 0`, `weekOffset ≤ 0`, `selectedSlot`) as `StateProvider`s or
  local widget state; `selectedSlot` seeds from the clock on screen open.

**Weekly average:** `total ÷ number of days with at least one entry` — *never* ÷ 7. Days
with no entries are excluded from the denominator entirely, and the day count is rendered
inline with the average. Unlogged days render as a neutral 6px `AppColors.border` stub in
the chart, with no number, never a zero-height bar.

## Screens

Build to the design README; it is pixel-exact. Summary of what exists:

| Screen | Route | Notes |
|---|---|---|
| S1 Protein | tab default | Ring, target pill, slot selector grid, food strip, grouped day log |
| S2 Progress | sub-tab | Average card, 7-day chart, week total |
| S3 Food cards | pushed | Catalog list, "New card" |
| S3b Card form | pushed | Name, grams stepper, 5-col icon grid |
| S4 Edit entry | pushed | Amount-each stepper, count stepper, slot pills, remove |
| Target | pushed | Single stepper, 20–300 by 5 |

Two implementation traps called out by the design, both easy to get wrong:

1. **Ring arcs must not render at zero fraction.** A zero-length dash with a round
   line-cap paints a *dot* — at 0g that leaves a coral mark on an empty ring (violating
   "simply empty"), and on any non-overfilled day the overfill dot darkens the fill's
   start cap.
2. **The slot selector is a 5-column grid, not a horizontal scroller.** With chips in a
   row the selected one lands off-screen whenever the clock seeds evening or night —
   exactly when someone is logging dinner.

Also: **future days and weeks are unreachable.** The forward arrow drops to `opacity 0.35`
and is inert at today / this week.

Undo toast: 4000ms, `AppColors.text` background, replaces (and resets the timer of) any
existing toast, positioned clear of the bottom nav.

## Navigation

`core/widgets/home_shell.dart`:

- Add `_NavTab(icon: Icons.restaurant_menu, label: 'Protein')` **before** the Profile
  entry (the design's `nutrition` icon does not exist in Flutter — see Icons above).
  Protein is index 4, Profile moves to 5. **Profile always stays last**; future feature
  tabs are inserted before it, never appended after.
- Add `5 => ...` to the `_body()` switch, with a `_proteinTab` int alongside `_workoutTab`
  selecting Protein vs Progress.
- The Protein tab keeps the scrollable bottom nav visible and renders its own two-segment
  pill switcher **inside** the screen. This deliberately differs from the Workouts tab,
  which replaces the bottom nav with a 3-item `NavigationBar` and therefore needs a "Home"
  escape item. Protein needs no "Home" segment because the bottom nav never disappears.
  Workouts is left unchanged.

## Firestore rules

Two new match blocks:

```
match /couples/{coupleId}/foods/{foodId} {
  allow read, write: if isCoupleMember(coupleId);
}

match /users/{userId}/proteinLog/{entryId} {
  allow read, write: if isSelf(userId);
}
```

The `foods` block nests inside the existing `match /couples/{coupleId}` alongside
`sharedNotes`. No existing rule is modified. `users/{userId}` write rules are **not**
relaxed — the target is a field on a document the owner already writes.

## Deliberate trade-offs

Recorded here so they are decisions rather than oversights.

1. **The target lives on `users/{userId}`, which the partner can read.** The existing rule
   at `firestore.rules:17-20` lets a paired partner read the whole user document. The
   target is therefore *not* private at the database level, though no screen ever displays
   it to them. Chosen for simplicity — no new document, no new rules block, and the profile
   stream already exists. The **log itself remains strictly private**, which is the
   invariant that actually matters. Revisit by moving the field to
   `users/{userId}/proteinSettings/settings` if this becomes uncomfortable.

2. **No Firestore rules tests.** `CLAUDE.md`'s Security section asks for an emulator test
   with an allow *and* a deny case per rules change; its Testing section says never write
   tests unless asked. Explicitly resolved in favour of skipping. The private-log rule will
   be verified by hand instead (see below). A silent regression in that rule would expose
   one partner's log to the other, so this is the highest-value test to add later if the
   position changes.

3. **`day` diverges from the workout feature's `Timestamp` convention** — see Decision 1.

## Verification

No automated tests (per above). Manual verification on a real Android device:

- Log the same card three times → one row showing `×3`, total = `3 × unit`.
- Decrement to 1, then once more → row disappears.
- Log, then Undo within 4s → count steps down (or row is removed at count 1).
- Edit an entry's amount in S4, then tap the original card → a **separate** row appears.
- Rename and then delete a food card → past entries keep their original name and icon.
- Log on two different days → the weekly average reads `total ÷ 2`, with "across 2 days
  logged" beside it; the other five days show flat stubs, not zeros.
- 0g day → empty ring, no coral dot, no urgent copy. Above target → overfilled ring, no
  celebration.
- Forward arrow inert at today and at the current week.
- **Privacy check:** signed in as partner B, confirm A's `users/{A}/proteinLog` reads are
  denied, and that the shared `foods` catalog reads and writes succeed for both.
