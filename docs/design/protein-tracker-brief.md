# Design brief: Daily Protein Tracker

**This is a brief for a designer — an input, not a handoff.** It describes what to
design. The expected output is an interactive HTML prototype plus a README spec, in the
same format as the existing `design_reminder/` and `design_feature_new/` bundles.

---

## 1. The app this belongs to

A private two-person Android app (Flutter) used by a couple. It currently has five
sections in a horizontally scrollable bottom nav: **Shared notes · Private notes ·
Workouts · Reminders · Profile**. The protein tracker becomes a **6th tab**.

The app already has an established visual system called **Peachy** — warm, cosy, pastel,
Material-style, rounded. **Do not invent a new palette.** Exact tokens in section 6.

> Note: an earlier internal document suggested "soft greens and blues" for this feature.
> Ignore that — it predates the app's design system. Peachy is already warm and calm and
> contains no alarming colours, which satisfies the intent. Consistency with the other
> five tabs matters more.

---

## 2. What the feature does

Tracks **one number only: grams of protein eaten today.** It is deliberately *not* a
macro or calorie tracker.

The user taps pre-made food cards ("Eggs", "Whey shake", "Chicken") and each tap adds
that food's protein value to the day's total. She never weighs food, never searches a
database, and never types unless she's creating a new card.

Both partners use it independently, each with their own target and their own log.

---

## 3. Design philosophy — the most important section

The intended user has a history of disordered eating and found mainstream tracking apps
(MyFitnessPal and similar) actively discouraging: large databases, precise counting, and
negative feedback when a goal is missed.

**The governing rule: progress is always framed positively, and missing a day is never
punished.**

### Hard constraints — never violate these

- **Never** show calories, BMI, weight, weight-loss projections, or comparisons to
  other people.
- **Never** use the words "failed", "missed", "over", "under", or "remaining".
- **Never** use red, or any error/warning colour, for any protein-related state.
- **No streaks.** No "5 days in a row" counters.
- **No pass/fail on a day.** There is no "goal met" checkmark, badge, or tick.
- Prefer "You've logged 60g today" over "40g to go". Show what exists, not what's absent.

### Deliberately unremarkable states

- At **0g**, nothing scolds or prompts urgently. The ring is simply empty.
- **Above target**, nothing celebrates and nothing warns. The ring is simply full or
  overfilled.

This restraint is intentional. Both extremes should feel unremarkable, not judged.

---

## 4. Screens to design

### S1 — Protein (main tab)

The default screen of the 6th nav tab.

- **Progress ring, top-centre.** The hero element. Fills toward the daily target as
  food is logged. Should look good empty, part-full, full, and overfilled.
- Current total in grams, and the target, near/inside the ring.
- **Day navigation:** previous / next day arrows, matching the pattern already used for
  weeks on the Workouts Progress screen. Today is the default.
- **Today's log list**, underneath the ring. Each row: food icon tile, food name, grams,
  and its time slot. Grouped or ordered by slot: **morning, noon, afternoon, evening,
  night**.
- **The food cards** the user taps to log. Design where these live — a horizontal strip,
  a grid below the log, or a sheet opened by a button. This is the core interaction and
  the most important thing to get right; see section 5.
- An affordance to **edit the daily protein target** (it is a per-user setting, and it
  lives here, not in Profile).
- An affordance to reach **food card management** (S3).
- Bottom nav visible.

### S2 — Progress (sub-tab)

The Workouts tab has a sub-navigation (Exercises | Progress | Home). Protein does the
same: **Protein | Progress | Home**.

- **Weekly average**, expressed as `total ÷ number of days logged` — *not* ÷ 7.
- The average must **always** appear with its day count, e.g. *"80g average across 3
  days logged"*. Never show a bare average.
- Previous / next week arrows.
- Optionally a simple 7-day bar chart of daily totals. If included: no target line
  drawn as a threshold to fall below, and bars for unlogged days must not read as
  failures.
- No streaks, no "days hit", no percentages of goal.

### S3 — Food cards management

**This screen was missing from the original spec — please design it.**

The catalog is shared between both partners and fully editable.

- List of all food cards: icon tile, name, protein grams.
- Add a new card.
- Edit or delete an existing card.
- **Add / edit card form:** name (text), protein grams (number), and an **icon grid
  picker** — the app already uses exactly this pattern on its "Add Exercise" screen, so
  match it. Roughly 15–25 food icons is plenty.
- Icon tiles cycle through a 5-colour pastel palette (section 6).

### S4 — Edit a log entry

Tapping an entry in the day's list lets her change its **time slot**, change the
**amount**, or **remove** it.

Removal must not be styled as destructive-red. It's a correction, not a failure.

### S5 — Empty states

Three, all needing warm and unhurried copy:

- **No food cards yet** (first run) — should lead into creating the first card.
- **Nothing logged today** — the ring at zero. Calm, no urgency.
- **No data on Progress** — nothing logged this week.

---

## 5. The key interaction (and the open question)

The intended flow is **one tap = one log**:

1. She taps the "Eggs" card.
2. 20g is logged immediately, into the time slot matching the current clock.
3. Done. No dialog, no confirmation.
4. If it was wrong, she taps the entry in the list and fixes the slot or amount (S4).

The reason is that friction is what made previous apps fail for her.

**This is the one decision not yet locked.** The alternative is a small form on every log
(pick slot → pick food → confirm amount) — slower, but more deliberate and harder to get
wrong. Please design **option A (one tap)** as the primary, but if while designing it you
find that one-tap feels careless, error-prone, or too easy to trigger accidentally, show
the alternative too and say so. Seeing it is exactly why we're designing before building.

Either way: a card's stored gram value **pre-fills** the amount. She should never retype
a number she has already recorded once.

---

## 6. Design tokens (Peachy) — use these exactly

**Colours**
| Token | Hex | Use |
|---|---|---|
| bg | `#FBF3EC` | Screen background |
| surface | `#FFFFFF` | Cards |
| primary | `#EF9270` | Coral — ring fill, buttons, FAB, active nav |
| onPrimary | `#FFFFFF` | Text/icons on coral |
| primarySoft | `#FBE0D3` | Tinted containers, ring track |
| text | `#4B3A33` | Body text |
| muted | `#A99184` | Secondary text, inactive icons |
| chipBg / chipText | `#F6E7DC` / `#9A6B4E` | Chips, pills, small tiles |
| border | `#F0E4DA` | Dividers, outlines |

There are `failText` / `failBg` tokens in the system — **do not use them anywhere in
this feature.**

**Food icon tile palette** (cycle by index, `{background, icon}`):
1. `#FBE0D3` / `#E07A54` (peach) 2. `#E7EEDD` / `#7FA05B` (sage)
3. `#FCE7C8` / `#D69A3E` (butter) 4. `#F6DDE0` / `#D06A82` (rose)
5. `#DDEAEA` / `#5E9A9A` (teal)

**Typography** — Baloo 2 for headings and numbers (600/700); Quicksand for body, labels
and uppercase eyebrows (700/800). Both Google Fonts.

**Radii** — cards 26px · small cards & inputs 18px · buttons 18px · FAB 22px ·
pills/chips 100px · icon tiles circular.

**Shadows** — cards `0 8px 22px rgba(180,120,90,0.13)`; primary buttons & FAB
`0 10px 22px rgba(224,122,84,0.32)`.

**Spacing** — screen padding 18–22px; card padding 13–20px; list gaps 10–13px.

**Icons** — Material Symbols (Outlined). Food icons available in the standard set
include `egg`, `egg_alt`, `set_meal`, `rice_bowl`, `ramen_dining`, `lunch_dining`,
`dinner_dining`, `bakery_dining`, `kebab_dining`, `local_pizza`, `local_drink`,
`local_cafe`, `blender`, `cookie`, `icecream`, `nutrition`, `restaurant`, `fastfood`,
`agriculture`. Stick to the standard set — no custom artwork.

---

## 7. Reference

The two existing handoffs in this repo show the house style and the expected output
format — `docs/design/design_reminder/README.md` is the closest match in size and
structure. Matching that level of detail (exact px, weights, colours per element, plus
the interactive HTML) is ideal.

## 8. Out of scope — do not design

- Calories, carbs, fats, TDEE, weight, BMI, or any body metric
- Barcode scanning, food search, or a nutrition database
- Notifications or reminders (the app has a separate Reminders feature for that)
- Sharing protein data between the two partners — logs are strictly private
- Onboarding flows, tutorials, or a first-run wizard
