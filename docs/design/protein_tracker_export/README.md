# Handoff: Daily Protein Tracker (Peachy)

## Overview
A 6th bottom-nav tab for the couple's private Flutter app. It tracks **one number only: grams of protein eaten today.** The user taps pre-made food cards and each tap adds that food's protein value to the day's total. No weighing, no database search, no typing except when creating a card.

Both partners use it independently — **each has their own target and their own log**. The food card catalog is **shared and editable by both**.

Source brief: `uploads/protein-tracker-brief.md`. Visual system: **Peachy**, identical to the Workouts and Reminders features.

## About the Design Files
`Protein Tracker.dc.html` is an **interactive HTML design reference**, not production code. Recreate it in Flutter with Material widgets and the codebase's existing patterns. Treat the HTML as the spec for layout, spacing, colour, typography, and interaction.

**Fidelity: high.** Colours, type, spacing, radii, and interactions are final; exact values below.

---

## ⚠️ Non-negotiable content rules

The intended user has a history of disordered eating. **Progress is always framed positively, and missing a day is never punished.** These are hard constraints, not preferences — a code reviewer should reject any violation:

- **Never** show calories, BMI, weight, weight-loss projections, or comparisons between the two partners.
- **Never** use the words **"failed", "missed", "over", "under", "remaining"** in any string.
- **Never** use red, or any error/warning colour, for any protein-related state. The system's `failText` / `failBg` tokens **must not appear in this feature.**
- **No streaks.** No "n days in a row".
- **No pass/fail on a day.** No "goal met" checkmark, badge, tick, or celebration.
- Show what exists, not what's absent: "You've logged 60g today", never "40g to go".
- At **0g** nothing scolds or prompts urgently. **Above target** nothing celebrates and nothing warns. Both extremes are deliberately unremarkable.

The target affordance therefore reads **"Target 110g"** — never a gap or a percentage.

---

## App structure & navigation

The bottom nav gains a **6th tab, Protein** (`nutrition` icon), and remains horizontally scrollable: Shared · Private · Workouts · Reminders · Profile · **Protein**. Container: white surface, top border 1px `#F0E4DA`, padding 10px 8px 12px, `overflow-x: auto`, gap 2px; each tab `flex: 0 0 84px`, column of [icon 25px][label Quicksand 12px weight 800, `white-space: nowrap`]. Active = `#EF9270`, inactive = `#A99184`.

Inside the tab, a **sub-nav** matching the Workouts tab's pattern: a two-segment pill switcher **Protein | Progress**. Track `#F3E8DF`, radius 100px, padding 4px; each segment `flex: 1`, padding 9px 0, radius 100px, Quicksand 13px weight 800. Active segment = white fill + `box-shadow: 0 2px 6px rgba(180,120,90,0.10)` + text `#4B3A33`; inactive = transparent + `#A99184`.

Screens:
- **S1 Protein** (default) and **S2 Progress** — sub-nav + bottom nav visible.
- **S3 Food cards** and **S3b Card form** — pushed, back arrow, no bottom nav.
- **S4 Edit entry** and **Target** — pushed, back arrow, no bottom nav.

---

## Screens

### S1 — Protein (main)

**Header** (padding 18px 20px 0): eyebrow "PROTEIN" (Quicksand 12px, weight 800, letter-spacing 1.6px, uppercase, `#A99184`); title = **"Today"**, **"Yesterday"**, or the date as `Sat 1 Aug` (Baloo 2, 29px, weight 600). On the right, **day arrows**: two 38×38 buttons, radius 14px, bg `#F6E7DC`, icon `chevron_left`/`chevron_right` 21px in `#9A6B4E`. **Future days are not reachable** — the next arrow drops to `opacity: 0.35` and is inert at today.

**Progress ring** (the hero, centred): 196×196 SVG, `viewBox="0 0 196 196"`, rotated `-90deg` so it starts at 12 o'clock. Three concentric `<circle cx="98" cy="98" r="82" fill="none" stroke-width="17">`:
1. **Track** — stroke `#FBE0D3`, always drawn.
2. **Fill** — stroke `#EF9270`, `stroke-linecap: round`, `stroke-dasharray: "{C×pct} {C}"` where `C = 2π×82 ≈ 515.2` and `pct = min(1, total ÷ target)`.
3. **Overfill** — stroke `#E07A54`, same cap, fraction `over = clamp((total − target) ÷ target, 0, 1)`, drawn on top.

> ⚠️ **Both foreground arcs must be hidden when their fraction is 0** (`stroke-opacity: 0`, or skip rendering). A zero-length dash with a round cap paints a **dot** — at 0g that leaves a coral mark on an empty ring, which violates the "simply empty" rule, and on any non-overfilled day the overfill dot darkens the fill's start cap.

Ring centre: total in Baloo 2 52px weight 700 `#4B3A33` with a 22px weight 600 `#A99184` "g", and beneath it "logged today" / "logged yesterday" / "logged that day" (Quicksand 13px, weight 700, muted).

**Target pill** (below ring, margin-top 12px): chip button, bg `#F6E7DC`, text `#9A6B4E`, Quicksand 13px weight 800, padding 9px 16px, radius 100px, `flag` icon 17px, label "Target {n}g". Opens the Target screen.

**"Log into" slot selector** — section label row (margin 24px 2px 11px): "LOG INTO" uppercase eyebrow on the left, a plain "Edit cards" text button (Quicksand 13px, weight 800, `#9A6B4E`) on the right opening S3.
Below it a **5-column grid** (`grid-template-columns: repeat(5, 1fr)`, gap 7px, margin-bottom 14px) — one cell per slot, in order **Morning · Noon · Aft. · Evening · Night**. Each: radius 16px, padding 10px 2px 9px, column layout, icon 19px over label Quicksand 11px weight 800. Selected → bg `#EF9270`, text white, shadow `0 6px 14px rgba(224,122,84,0.32)`; unselected → bg `#F6E7DC`, text `#9A6B4E`.
Slot icons: `wb_twilight`, `light_mode`, `wb_sunny`, `nights_stay`, `bedtime`.

> Must be a **grid, not a horizontal scroller**. With five chips in a row the selected one lands off-screen whenever the clock seeds evening or night — precisely when someone is logging dinner — leaving no visible answer to "which slot am I logging into?". "Afternoon" abbreviates to **"Aft."** to fit 412px; the full word is used everywhere else.

The selector **defaults to the slot matching the current clock** and is user-overridable before tapping a card.

**Food card strip** — horizontal scroller, gap 11px, bleeding to the screen edges (`margin: 0 -20px` with 20px side padding). Each card: `flex: 0 0 98px`, white surface, radius 22px, card shadow, padding 14px 10px, column with gap 8px — [circular 50×50 tile in its pastel pair, icon 27px] [name Baloo 2 14px weight 600, single line ellipsis] [grams pill: Quicksand 12px weight 800, `#9A6B4E` on `#F6E7DC`, padding 3px 10px, radius 100px]. A trailing **"New card"** tile closes the strip: 2px dashed `#F0E4DA`, transparent, `add` icon 26px, muted.

**Tapping a card logs it immediately** — see Key interaction.

**Day log** — heading "TODAY'S LOG" (or "THE LOG" on other days). Grouped by slot in fixed order; **empty slots are not rendered**. Group header: slot icon 17px muted, slot name (Quicksand 12px, weight 800, letter-spacing 0.8px, uppercase, muted), a 1px `#F0E4DA` rule filling the gap, then the group's gram sum on the right.
**Entry row**: white surface, radius 18px, card shadow, padding `12px 10px 12px 14px`, margin-bottom 10px. It is **two** buttons side by side:
- the main region (opens S4) — [circular 44×44 tile, icon 24px] [name Baloo 2 16px weight 600 + optional **×n** repeat pill (Quicksand 12px weight 800, `#9A6B4E` on `#F6E7DC`, padding 2px 8px, radius 100px) + sub-line] [total grams, Baloo 2 18px weight 700, `#E07A54`].
- the **decrement button** — 44×44, transparent, radius 14px, icon `#A99184`.
Sub-line = the slot name, or `"Morning · 12g each"` when the row is a repeat.

### S2 — Progress

Header mirrors S1 with **week arrows** and the title "This week" or `28 Jul – 3 Aug`. Future weeks unreachable (same 0.35 opacity treatment).

**Average card**: bg `#FBE0D3`, radius 26px, padding 22px, centred. Value Baloo 2 46px weight 700 + 21px "g", and beneath it, always, **"average across {n} days logged"** (Quicksand 14px, weight 700, `#9A6B4E`).
> The average is **total ÷ number of days logged**, *not* ÷ 7, and **must never render without its day count**.

**"Each day" chart**: white card, radius 26px, padding 20px. Seven columns, gap 9px, 132px tall, bars aligned to the bottom, `border-radius: 8px 8px 5px 5px`, labels M T W T F S S. A logged day → height `round(v ÷ maxV × 100)%`, fill `#EF9270`, its value shown above the bar. An unlogged day → **a neutral 6px stub in `#F0E4DA` with no number** — deliberately a flat placeholder, not a zero-height gap that reads as a hole.
> **No target line.** No percentages, no "days hit".

**Week total card**: white, radius 26px, padding 18px 20px, `local_florist` icon 30px primary + "{n}g altogether" (Baloo 2 16px weight 600) over "across the whole week" (Quicksand 13px weight 700 muted).

### S3 — Food cards

Title "Food cards" (Baloo 2 28px weight 600) with the sub-line "Shared between you both." (Quicksand 13px, weight 700, muted).
**Row** per card: white, radius 18px, card shadow, padding 12px 14px, margin-bottom 10px — [circular 46×46 tile, icon 25px] [name Baloo 2 16px weight 600 + "{n}g protein" Quicksand 12px weight 700 muted] [`edit` icon 22px muted]. Opens S3b.
Fixed bottom: primary **"New card"** button with `add` icon.

### S3b — Card form (add / edit)

Back arrow left; when editing, a **"Delete"** text button on the right — `delete` icon 19px + label, Quicksand 13px weight 800, in **`#9A6B4E`, never red**.
Title "New food card" / "Edit card". Centred **92×92 circular preview** in the card's pastel pair with the chosen icon at 46px.
- **Name** — uppercase label; input full-width, white, radius 18px, card shadow, padding 15px 16px, Baloo 2 17px weight 600, placeholder "e.g. Whey shake". Blank saves as "New food".
- **Protein** — white card, radius 18px, padding 16px 20px: [− 46×46 radius 16px `#F6E7DC`/`#9A6B4E`] [value Baloo 2 40px weight 700 + "g"] [+ 46×46 radius 16px primary/white]. Steps by 1, clamped 1–120.
- **Icon** — `grid-template-columns: repeat(5, 1fr)`, gap 9px, cells `aspect-ratio: 1`, radius 16px, symbol 24px. Selected → primary bg, white icon, glow shadow; unselected → `#F6E7DC` / `#9A6B4E`. **Matches the Add Exercise icon picker.** Twenty icons: `egg`, `egg_alt`, `set_meal`, `rice_bowl`, `ramen_dining`, `lunch_dining`, `dinner_dining`, `bakery_dining`, `kebab_dining`, `local_pizza`, `local_drink`, `local_cafe`, `blender`, `cookie`, `icecream`, `nutrition`, `restaurant`, `fastfood`, `agriculture`, `grocery`.

Fixed bottom: "Create card" / "Save changes".

### S4 — Edit entry

Header: 58×58 circular tile + food name (Baloo 2 26px weight 600) over the full date ("Saturday 1 August").
- **Amount each** — stepper card, identical geometry to the protein stepper, edits the **per-serving** value (1–200).
- **How many** — stepper card showing `×{count}` (1–20).
- Beneath: "{n}g altogether" (Quicksand 13px, weight 700, muted).
- **Time of day** — wrapping pill row, one per slot, `padding 10px 16px`, radius 100px, icon 18px + full slot name. Selected → primary/white + glow; unselected → `#F6E7DC` / `#9A6B4E`.
- **Removal** — full-width button, **bg `#F6E7DC`, text `#9A6B4E`** (never red), radius 18px, padding 15px, `backspace` icon + **"Take this off the list"**. It is a correction, not a failure.

Fixed bottom: "Save changes".

### Target screen

Title "Daily target" with the sub-line "Just a marker for the ring to fill toward. Yours only — change it whenever you like."
One large stepper card (radius 26px, padding 24px 20px; buttons 52×52 radius 18px; value Baloo 2 52px weight 700). **Steps by 5, clamped 20–300.** Fixed bottom "Save target". The target is **per-user** and lives here, not in Profile.

### S5 — Empty states

- **No food cards** (first run, shown on S1 in place of the strip and on S3): `restaurant` 42px primary, "Let's make your first card", "Cards are the foods you eat often. One tap logs them.", primary pill "Create a card". S3's variant reads "No cards yet" / "Start with something you eat most days."
- **Nothing logged today**: `bookmark_border` 40px `#D9C4B6`, "Nothing here yet", "Tap a card above whenever you eat something." On a past day the body reads "Nothing was logged on this day." The ring simply sits empty — no urgency.
- **No data on Progress**: `insights` 42px `#D9C4B6`, "Nothing logged this week", "Whenever you log something, it'll show up here."

---

## Key interaction — one tap = one log

**Option A (one tap) is the design.** Tapping a food card immediately appends an entry into the currently selected slot, with the card's stored grams. No dialog, no confirmation. Friction is what made previous apps fail for this user.

**Two additions came out of designing it, both of which should ship:**

1. **The slot selector is visible up front** (rather than the slot being inferred silently from the clock and only correctable afterwards). It still defaults to the clock, so the fast path is unchanged, but the answer to "where is this going?" is on screen before the tap.
2. **A 4-second Undo toast** follows every log. The strip is a scroll surface, so a stray tap can log silently; Undo makes the correction one tap instead of a trip through S4. This preserves zero-friction logging without the slower confirm-every-log alternative, which is why the alternative is **not** specified here.

**Toast**: absolute, left/right 16px, bottom 82px (clear of the nav), bg `#4B3A33`, radius 18px, padding 13px 15px — `check_circle` 20px in `#FBE0D3`, message in `#FFF6EF` (Quicksand 14px weight 700), and an **"Undo"** button in `#F5B79A` (Quicksand 13px weight 800). Auto-dismisses after 4000ms; replaced (timer reset) if another log happens first.

### Repeat logging — stacking

Tapping the same card repeatedly **does not create multiple rows.** A new tap merges into an existing entry when **day, slot, cardId, and per-serving amount all match**; otherwise it creates a new row.

- Merged rows show a **×n** pill and the sub-line "{slot} · {unit}g each"; the right-hand figure is the **total** (`unit × count`).
- The row's delete button **decrements**: icon `remove` while `count > 1`, switching to `backspace` at `count == 1`, where it removes the row.
- **Undo mirrors this** — it steps a merged count back down rather than deleting the whole stacked row.
- An entry whose amount was edited in S4 to a custom value no longer matches the card's stored value, so it stays a separate row.

A card's stored gram value always **pre-fills** the amount. The user should never retype a number she has already recorded once.

---

## State Management

Use whatever the codebase prefers (`ChangeNotifier`/Provider, Riverpod, Bloc).

```
FoodCard = { id: int, name: String, grams: int, icon: String }   // shared catalog

LogEntry = {
  id: int,
  day: DateTime,        // date only
  cardId: int,
  name: String,         // snapshotted at log time
  icon: String,         // snapshotted at log time
  unit: int,            // grams per serving
  count: int,           // ≥ 1
  slot: Slot,           // morning | noon | afternoon | evening | night
}
// entry total = unit × count
```

Per-user: `targetGrams: int` (default 110), and the user's own `entries`. Shared: `cards`.
View state: `dayOffset` (≤ 0), `weekOffset` (≤ 0), `selectedLogSlot` (defaults to the clock-derived slot), plus editor drafts and the undo toast.

- `name`/`icon` are **snapshotted onto the entry** so renaming or deleting a card never rewrites history.
- Tile colours cycle the 5-colour pastel palette **by the card's index in the catalog**, so a food keeps its colour across every screen.
- Clock → slot: `<11:00` morning · `<14:00` noon · `<17:00` afternoon · `<21:00` evening · else night.
- **Persistence**: local, per the codebase's existing storage. Logs are strictly **private to each partner**; only the card catalog syncs between them.

---

## Design Tokens (Peachy)

| Token | Hex | Use |
|---|---|---|
| bg | `#FBF3EC` | Screen background |
| surface | `#FFFFFF` | Cards |
| primary | `#EF9270` | Ring fill, buttons, FAB, active states |
| onPrimary | `#FFFFFF` | Text/icons on coral |
| primarySoft | `#FBE0D3` | Ring track, tinted containers |
| overfill | `#E07A54` | Overfill arc, entry gram figures |
| text | `#4B3A33` | Body text, toast background |
| muted | `#A99184` | Secondary text, inactive icons |
| chipBg / chipText | `#F6E7DC` / `#9A6B4E` | Chips, pills, steppers, small tiles |
| border | `#F0E4DA` | Dividers, dashed outlines, unlogged bars |
| subtle | `#D9C4B6` | Empty-state icons |

`failText` / `failBg` — **not used anywhere in this feature.**

**Food tile palette** (cycled by catalog index, `{background, icon}`):
`#FBE0D3`/`#E07A54` · `#E7EEDD`/`#7FA05B` · `#FCE7C8`/`#D69A3E` · `#F6DDE0`/`#D06A82` · `#DDEAEA`/`#5E9A9A`

**Typography** — **Baloo 2** (600/700) for headings and numbers; **Quicksand** (700/800) for body, labels, and uppercase eyebrows. Both Google Fonts (`google_fonts` package or bundled .ttf).

**Radii** — cards 26px · small cards, inputs & buttons 18px · food strip cards 22px · steppers & grid cells 16px · day arrows 14px · pills/chips 100px · icon tiles circular.

**Shadows** — cards `0 8px 22px rgba(180,120,90,0.13)` · primary buttons `0 10px 22px rgba(224,122,84,0.32)` · active chips `0 6px 14px rgba(224,122,84,0.32)` · toast `0 10px 26px rgba(75,58,51,0.28)` · active sub-nav segment `0 2px 6px rgba(180,120,90,0.10)`.

**Spacing** — screen padding 18–22px · card padding 12–20px · list gaps 10–13px.

**Icons** — Material Symbols (Outlined); use `Icons` or the `material_symbols_icons` package. No custom artwork.
Feature icons: `nutrition` (nav), `chevron_left`/`chevron_right` (day & week), `flag` (target), `add`, `remove`, `backspace`, `edit`, `delete`, `check_circle` (toast), `arrow_back`, `restaurant` / `bookmark_border` / `insights` (empty states), `local_florist` (week total), and the five slot icons above.

---

## Out of scope — do not build
Calories, carbs, fats, TDEE, weight, BMI, or any body metric · barcode scanning, food search, or a nutrition database · notifications (the Reminders feature owns those) · sharing protein data between partners · onboarding, tutorials, or a first-run wizard.

## Files
- `Protein Tracker.dc.html` — the interactive prototype: all six screens plus logic. Open it in a browser to click through the real behaviour.

This README is written to be **self-sufficient** — every screen, token, and interaction is specified above, so the feature can be built from this document alone.
