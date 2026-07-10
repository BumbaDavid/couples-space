# Handoff: Workout & Gains Tracker (Peachy direction)

## Overview
A new feature for a Flutter/Dart phone app that lets a user track workout exercises and progress. The user sees a list of exercises, adds new ones, opens an exercise detail page (name, target body part, icon), and logs entries — reps, sets, and whether the set went to failure. A Progress tab summarizes weekly gains.

The chosen visual direction is **"Peachy"**: a cute & cozy, pastel, Material-style aesthetic.

## About the Design Files
The files in this bundle are **design references created in HTML** — interactive prototypes showing the intended look and behavior. They are **not** production code to copy directly.

Your task is to **recreate these designs in the target codebase**, which is a **Flutter/Dart app**. Use Flutter's established patterns and widget library (Material widgets, `ThemeData`, custom widgets) — do not attempt to port the HTML/CSS/JS. Treat the HTML as the spec for layout, spacing, color, typography, and interaction.

## Fidelity
**High-fidelity (hifi).** Colors, typography, spacing, radii, and interactions are final. Recreate the UI faithfully in Flutter. Exact values are listed under Design Tokens below.

## App structure & navigation
A single-feature module with 5 screens and this navigation graph:

- **Exercise List** (home) — bottom nav item 1. FAB → Add Exercise. Tapping a row → Exercise Detail.
- **Progress** — bottom nav item 2.
- **Exercise Detail** — pushed from list. Back arrow → list. "Add entry" button → Add Entry.
- **Add Entry** — pushed from detail. Back arrow / Save → returns to detail.
- **Add Exercise** — pushed from list (FAB). Back arrow → list. "Create exercise" → new exercise's detail.

The list & progress screens show the bottom navigation bar. The three "pushed" screens (detail, add entry, add exercise) show a top back arrow and **no** bottom nav.

## Screens / Views

### 1. Exercise List
- **Purpose**: Browse all exercises; entry point to add or open one.
- **Layout**: Vertical column. Header (padding 22px 22px 10px), scrollable list (padding 8px 18px), bottom nav (fixed). A circular-ish FAB floats bottom-right (right 18px, bottom 84px, above the nav).
- **Header**: Eyebrow label "LET'S MOVE" (12px, weight 800, letter-spacing 1.6px, uppercase, muted color). Title "My Workouts" (Baloo 2, 31px, weight 600, text color).
- **Exercise row (card)**: full-width button, background surface white, border-radius 26px, soft shadow, padding 13px, margin-bottom 13px. Row = [icon tile] [name + subtitle] [chevron_right].
  - Icon tile: 54×54, border-radius 50% (circle), background = per-exercise pastel tile bg, centered Material Symbol icon 29px in tile fg color.
  - Name: Baloo 2, 17px, weight 600. Subtitle: Quicksand, 13px, weight 700, muted — format `"{bodyPart} · {n} session(s)"`.
  - Chevron: Material Symbol `chevron_right`, 24px, muted.
- **FAB**: 62×62, border-radius 22px, background primary coral, white `add` icon 31px, glow shadow `0 10px 22px rgba(224,122,84,0.32)`.
- **Bottom nav**: white surface, top border 1px, padding 10px 0 12px. Two items (Home, Progress), each a column of [icon 25px][label 12px weight 800]. Active item uses primary color; inactive uses muted. Icons: `home`, `bar_chart`.

### 2. Exercise Detail
- **Purpose**: See an exercise's stats and history; log a new entry.
- **Layout**: Top bar with back arrow only (padding 14px), scrollable body (padding 0 20px), fixed bottom "Add entry" button with a gradient fade behind it.
- **Hero (centered)**: 88×88 icon tile, border-radius 50%, tile bg color, Material Symbol 46px in tile fg. Name (Baloo 2, 27px, weight 600). Body-part chip below: pill, background chipBg, text chipText, 13px weight 700, padding 6px 14px, border-radius 100px.
- **Stat row**: 3 equal cards (gap 10px, margin-top 22px). Each: surface bg, border-radius 18px, shadow, padding 14px 8px, centered. Big value (Baloo 2, 25px, weight 700) + uppercase label (Quicksand, 11px, weight 800, muted). Labels: "Sessions", "Best reps", "Total sets".
  - `sessions` = entry count; `bestReps` = max reps across entries; `totalSets` = sum of sets.
- **Volume chart card** (shown only if entries exist): surface bg, radius 26px, shadow, padding 18px. Title "Volume per session" (Baloo 2, 16px, weight 600). A flex row of bars, container height 104px, gap 10px, bars align to bottom. Each bar: full width of its column, height = `round(volume / maxVolume * 100)%` (min-height 6px), background primary coral, border-radius `8px 8px 5px 5px`, with the entry's date label (11px, weight 700, muted) below. `volume = reps * sets`.
- **History**: section title "History" (Baloo 2, 16px, weight 600, margin 22px 4px 12px). Entries listed **newest first**. Each row: surface card, radius 18px, shadow, padding 13px 15px, margin-bottom 10px. Row = [date tile 46×46, radius ~40%, chipBg, date text Baloo 2 14px] [ "{reps} reps × {sets} sets" (Baloo 2 16px weight 600) + "{volume} total reps" (Quicksand 12px weight 700 muted) ] [ optional Failure badge ].
  - Failure badge (only when `failure == true`): pill, background failBg2, text failText, 11px weight 800, padding 5px 9px, with a `local_fire_department` icon 14px + "Failure".
  - Empty state (no entries): centered `note_add` icon 38px muted + "No entries yet — log your first set!".
- **Add entry button** (fixed bottom): full-width, primary coral bg, white text (Baloo 2, 17px, weight 600), padding 16px, border-radius 18px, glow shadow, with `add` icon 22px + "Add entry".

### 3. Add Entry
- **Purpose**: Log a set for the current exercise.
- **Layout**: Back arrow top bar, scrollable body (padding 6px 22px), fixed bottom "Save entry" button.
- **Header**: eyebrow = exercise name (uppercase, 12px, weight 800, muted). Title "Log a set" (Baloo 2, 28px, weight 600).
- **Reps stepper card**: surface bg, radius 26px, shadow, padding 20px, margin-bottom 14px. Uppercase label "Reps". Row: [− button][value][+ button]. Minus button 46×46, radius 16px, chipBg bg, chipText icon. Value: Baloo 2, 44px, weight 700, min-width 70px, centered. Plus button 46×46, radius 16px, primary bg, white icon. Icons `remove` / `add`, 26px. Reps min = 1, default 10.
- **Sets stepper card**: identical to Reps. Sets min = 1, default 3.
- **Failure toggle card**: full-width button (surface bg, radius 26px, shadow, padding 18px 20px). Left: "Went to failure?" (Baloo 2, 17px, weight 600) + "Last set with nothing left" (Quicksand, 12px, weight 700, muted). Right: a toggle switch — track 54×31, radius 100px, background = primary when on / border color when off; knob 25×25 white circle, top 3px, left 3px → 26px on, `box-shadow 0 2px 5px rgba(0,0,0,0.2)`, transition 0.2s. Default off.
- **Save entry button** (fixed bottom): same style as detail's primary button, text "Save entry". Saving appends `{reps, sets, failure, date:"Today"}` to the exercise's entries and returns to detail.

### 4. Add Exercise
- **Purpose**: Create a new exercise.
- **Layout**: Back arrow top bar, scrollable body (padding 6px 22px), fixed bottom "Create exercise" button.
- **Title**: "New exercise" (Baloo 2, 28px, weight 600).
- **Icon preview (centered)**: 92×92 tile, border-radius 50%, background primarySoft, Material Symbol 48px in primary color. The icon is **derived from the selected body part** (see mapping) and updates live.
- **Name field**: uppercase label "Name". Text input: full-width, surface bg, radius 18px, shadow, padding 15px 16px, Baloo 2 17px weight 600, placeholder "e.g. Lunges", no border/outline.
- **Body part chips**: uppercase label "Body part". Wrapping flex row, gap 9px. Each chip: pill button, padding 10px 16px, radius 100px, Quicksand 14px weight 700. Selected chip: primary bg + white text + glow shadow. Unselected: chipBg bg + chipText text, no shadow. Options: Chest, Back, Legs, Shoulders, Arms, Core, Cardio.
- **Create exercise button** (fixed bottom): primary style, text "Create exercise". On save: name defaults to "New Exercise" if blank; new exercise gets the derived icon and empty entries; navigates to its detail.

### 5. Progress
- **Purpose**: Weekly summary of activity/gains ("nice to have" depth).
- **Layout**: Header (eyebrow "THIS WEEK" + title "Your Gains", Baloo 2 31px), scrollable body (padding 8px 20px), bottom nav (Progress active).
- **Stat row**: 3 cards (same style as detail stats): "Workouts", "Day streak", "Total reps".
- **Weekly volume chart card**: surface bg, radius 26px, shadow, padding 20px. Title "Weekly volume". Bars container height 130px, gap 9px, 7 day columns (M T W T F S S). Bar height = `round(v / maxV * 100)%` (min-height 5px), background primary when v>0 else border color, radius `8px 8px 5px 5px`; day label below (12px, weight 800, muted).
- **Encouragement card**: background primarySoft, radius 26px, padding 18px 20px, row = [`emoji_events` icon 34px primary] + [ "Best week yet!" (Baloo 2 16px 600) + "You're up 18% on last week. Keep it cozy." (Quicksand 13px 700, chipText) ].

## Interactions & Behavior
- **Navigation**: list ⇄ progress via bottom nav; detail/add-entry/add-exercise are pushed views with a back arrow. Recommend Flutter `Navigator.push` for pushed views and an `IndexedStack`/`NavigationBar` for the list↔progress tabs.
- **Steppers**: `−`/`+` adjust reps/sets by 1; clamp at min 1.
- **Failure toggle**: tapping anywhere on the card toggles state; knob slides 0.2s.
- **Save entry**: appends entry, sets its date label to "Today", pops back to detail. Detail stats/chart/history recompute.
- **Create exercise**: appends exercise (with body-part-derived icon), opens its detail.
- **Transitions**: keep subtle. Toggle knob & track color animate 200ms. Everything else uses standard Material page transitions.
- No loading/error/network states in this prototype (local state only).

## State Management
Per-feature state (in the prototype it's a single component; in Flutter use a `ChangeNotifier`/`Provider`, `Riverpod`, or `Bloc` as the codebase prefers):
- `screen` (enum: list | detail | addEntry | addExercise | progress) — or Flutter navigation instead.
- `selectedExerciseId: int`
- `exercises: List<Exercise>` where `Exercise = { id, name, bodyPart, icon, entries: List<Entry> }` and `Entry = { reps:int, sets:int, failure:bool, date:String }`.
- `newEntry: { reps:int=10, sets:int=3, failure:bool=false }` — draft for Add Entry.
- `newExercise: { name:String, bodyPart:String='Chest' }` — draft for Add Exercise.
- `weekly: List<{ day:String, volume:int }>` — Progress chart data.
- Derived: sessions (entries.length), bestReps (max reps), totalSets (sum sets), volume (reps×sets), chart heights (normalized %), weekly totals.
- **Persistence**: entries/exercises should persist across app launches — use the codebase's existing storage (e.g. `shared_preferences`, Isar, Drift, or a backend). The prototype uses in-memory seed data.

### Body-part → icon mapping (Material Symbols names)
```
Chest      -> exercise
Back       -> rowing
Legs       -> directions_run
Shoulders  -> sports_gymnastics
Arms       -> fitness_center
Core       -> self_improvement
Cardio     -> directions_bike
```
Chevron `chevron_right`, back `arrow_back`, add `add`, stepper `remove`/`add`, failure `local_fire_department`, nav `home`/`bar_chart`, progress trophy `emoji_events`, empty state `note_add`.

## Design Tokens (Peachy)
**Colors**
- bg (screen background): `#FBF3EC`
- surface (cards): `#FFFFFF`
- primary (coral): `#EF9270`
- onPrimary: `#FFFFFF`
- primarySoft: `#FBE0D3`
- primaryGlow (button shadow color): `rgba(224,122,84,0.32)`
- text: `#4B3A33`
- muted (secondary text): `#A99184`
- chipBg: `#F6E7DC`
- chipText: `#9A6B4E`
- border / divider: `#F0E4DA`
- failText: `#C25B3A`
- failBg2: `#FBE0D3`

**Exercise tile palette** (cycled by list index; `{background, iconColor}`):
1. `#FBE0D3` / `#E07A54` (peach)
2. `#E7EEDD` / `#7FA05B` (sage)
3. `#FCE7C8` / `#D69A3E` (butter)
4. `#F6DDE0` / `#D06A82` (rose)
5. `#DDEAEA` / `#5E9A9A` (teal)

**Typography**
- Headings: **Baloo 2** (weights 400/500/600/700). Titles ~28–31px/600, card titles 16–17px/600, big numbers 25–44px/700.
- Body/labels: **Quicksand** (weights 400/500/600/700). Body 13–14px, uppercase eyebrow labels 11–13px weight 800, letter-spacing ~0.5–1.6px.
- Both are Google Fonts.

**Radius**: cards 26px, small cards/fields 18px, stepper buttons 16px, FAB 22px, primary buttons 18px, pills/chips 100px, icon tiles circular (50%).

**Shadow**: cards `0 8px 22px rgba(180,120,90,0.13)`; primary buttons/FAB glow `0 10px 22px rgba(224,122,84,0.32)`.

**Spacing**: screen horizontal padding 18–22px; card padding 13–20px; list gaps 10–13px; stat gaps 10px.

## Assets
- **Icons**: Google **Material Symbols (Outlined)** — line style. In Flutter use the built-in `Icons` set (Material) or the `material_symbols_icons` package for exact matches. No custom image assets are used.
- **Fonts**: Baloo 2 and Quicksand from Google Fonts — add via `google_fonts` package or bundle the .ttf files in `pubspec.yaml`.
- No photos or illustrations.

## Files
Design reference files included in this bundle:
- `Workout Tracker.dc.html` — the presentation board (both explored directions; **Peachy = `#1a`** is the approved one). Its theme object `themeA` holds the exact Peachy tokens.
- `WorkoutApp.dc.html` — the interactive app prototype (all 5 screens + logic). This is the primary behavioral reference.
- `android-frame.jsx` — device bezel used only to frame the prototype; **not** part of the feature (ignore for implementation).

> Note: the `.dc.html` files use a component runtime for the prototype. Open them for reference/behavior; implement the feature natively in Flutter. Ignore the Lavender direction (`#1b`) — it was an exploration that was not chosen.
