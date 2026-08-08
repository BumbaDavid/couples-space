# Feature idea: Daily protein tracker

**Discussed:** 2026-08-01
**Status:** Scoped — design in progress, not yet implemented
**Source doc:** user-written summary (`protein_tracker_feature_summary.md`), refined in a
grilling session. This note is the authoritative record of what was actually decided;
where the two disagree, this note wins.

## What it is

A single-metric tracker for daily protein intake. Deliberately **not** a macro tracker:
no calories, no BMI, no weight projections, no comparison to other users.

The feature exists because mainstream tracking apps (MyFitnessPal et al.) were
psychologically discouraging for the intended user. The whole design is organised
around one rule: **progress is framed positively and missing a day is never punished.**

## Hard constraints (non-negotiable)

- Never display calories, BMI, weight-loss projections, or user comparisons.
- Never use the words "failed" or "missed" in the UI.
- No red / error colouring for any protein state.
- No daily streaks — they motivate until broken, then become shame.
- No pass/fail on a day. There is no "target met" boolean anywhere.

## Decisions

### Scope & placement
- Available to **both** users, each with their own target and their own log.
- New **6th tab** in the horizontally scrollable bottom nav.
- Inside it, a sub-nav mirroring Workouts: **Protein | Progress | Home**.
- Protein target is editable (not hardcoded to 100g) and lives on the protein screen,
  not in Profile.
- No protein-specific notifications — [[reminders-feature]] already covers "shake time".

### Data model
- **Shared catalog:** `couples/{coupleId}/foods/{foodId}` — `{name, proteinGrams, icon}`.
  Both partners maintain one list; food facts ("an egg has ~6g") are shared knowledge,
  not personal data.
- **Private log:** `users/{userId}/proteinLog/{entryId}` — never visible to the partner,
  even though this is a couples app. This is a hard invariant.
- Log entries **snapshot** name + grams at log time rather than referencing the card.
  Editing a card must never rewrite history or change a past weekly average.
- Food cards are fully editable: add, rename, change grams, change icon, delete.

### Logging
- **One tap** on a card logs it immediately; time slot is auto-derived from the current
  clock and can be corrected afterwards. (Chosen over an always-open form — friction is
  what made previous apps fail for this user. Provisional pending the visual design.)
- Multiple entries per day, displayed as a list.
- Time is a **slot**, not a timestamp: morning, noon, afternoon, evening, night.
- Retroactive logging supported; prev/next **day** arrows, same pattern as the workout
  Progress screen's week arrows.
- Food icons chosen from a **grid picker**, same interaction as Add Exercise. Material's
  built-in food icons suffice — no new dependency. Tiles use `AppColors.tilePalette`.

### Framing / maths
- **Weekly average = total ÷ days logged**, not ÷ 7. Dividing by 7 lets an unlogged day
  silently drag the number down, which is the punishment signal the design removes.
- The average is **always shown with the day count** — "80g average across 3 days
  logged" — because a bare average over a self-selected denominator is misleading.
- **Nothing special happens** at 0g or above target. No celebration, no warning. The
  ring simply sits empty or overfilled, unremarked.
- Daily screen: progress **ring** top-centre, log list underneath.

### Precision
Every gram value is an estimate, and the running total is a sum of estimates. This was
accepted rather than solved: because the user enters the gram value on each card
herself, the numbers are her own consistent estimates. No rounding or softening logic.

## Open questions

1. **One-tap (option A) is provisional.** The user is producing a visual design first
   and may switch to an explicit add-log form if one-tap reads badly on screen.
2. **How far back can she log?** A 7-day cap was proposed but not adopted — with day
   arrows there is no natural stopping point. Current assumption: no limit.
3. Whether editing a log entry is tap-to-open or swipe — deferred to the design.

## Deferred
- Tracking carbs and fats. The source doc gives targets for both; they are context only.
- Any calorie/TDEE surface. Deliberately excluded, not merely unbuilt.

## Build implications
- Two new Firestore collections → two new `match` blocks in `firestore.rules`, each
  needing an allow **and** a deny emulator test per project convention.
- The shared catalog is the project's second couple-scoped collection after shared
  notes; the private log follows the same shape as workout data.

## Note on the source document
The original summary contains a detailed personal health profile (weight, medication,
eating history) and specific nutrition figures (TDEE, calorie targets, the 100g number).
Those are context for *why* the feature is shaped this way — they are **not** app
content and must never surface in the UI. The specific figures should track whatever a
doctor or dietitian advises, which is why the target is a setting rather than a constant.
