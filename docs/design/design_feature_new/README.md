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
A single-feature module with 6 screens and this navigation graph:

- **Exercise List** (home) — bottom nav item 1. Has two view modes (flat / grouped by day, see below). FAB → Add Exercise. Tapping a row → Exercise Detail.
- **Progress** — bottom nav item 2.
- **Exercise Detail** — pushed from list. Back arrow → list. "Add entry" button → Add Entry.
- **Add Entry** — pushed from detail. Back arrow / Save → returns to detail.
- **Add Exercise** — pushed from list (FAB) or from the Pick Exercises screen. Back arrow → list. "Create exercise" → new exercise's detail.
- **Pick Exercises** — pushed from a day's "Add exercises" button in the grouped list. Back arrow / "Done" → list.

The list & progress screens show the bottom navigation bar. The pushed screens (detail, add entry, add exercise, pick exercises) show a top back arrow and **no** bottom nav.

## Screens / Views

### 1. Exercise List
- **Purpose**: Browse all exercises; entry point to add or open one.
- **Layout**: Vertical column. Header (padding 22px 22px 10px), scrollable list (padding 8px 18px), bottom nav (fixed). A circular-ish FAB floats bottom-right (right 18px, bottom 84px, above the nav).
- **Header**: Eyebrow label "LET'S MOVE" (12px, weight 800, letter-spacing 1.6px, uppercase, muted color). Below it a row with the title "My Workouts" (Baloo 2, 31px, weight 600) on the left and the **group toggle button** on the right.
- **Group toggle button**: pill, padding 9px 14px, radius 100px, Quicksand 13px weight 800, with a leading Material Symbol 18px.
  - Off (flat mode): background chipBg, text chipText, no shadow, icon `calendar_view_week`, label "By day".
  - On (grouped mode): background primary, text white, glow shadow, icon `view_agenda`, label "All".
  - Tapping switches the list body between **flat mode** and **grouped mode**. This is a pure view toggle — it does not change data.
- **Exercise row (card)**: full-width button, background surface white, border-radius 26px, soft shadow, padding 13px, margin-bottom 13px. Row = [icon tile] [name + subtitle] [chevron_right].
  - Icon tile: 54×54, border-radius 50% (circle), background = per-exercise pastel tile bg, centered Material Symbol icon 29px in tile fg color.
  - Name: Baloo 2, 17px, weight 600. Subtitle: Quicksand, 13px, weight 700, muted — format `"{bodyPart} · {n} session(s)"`.
  - Chevron: Material Symbol `chevron_right`, 24px, muted.
- **FAB**: 62×62, border-radius 22px, background primary coral, white `add` icon 31px, glow shadow `0 10px 22px rgba(224,122,84,0.32)`.
- **Bottom nav**: white surface, top border 1px, padding 10px 0 12px. Two items (Home, Progress), each a column of [icon 25px][label 12px weight 800]. Active item uses primary color; inactive uses muted. Icons: `home`, `bar_chart`.

#### 1a. Flat mode (default)
A single scrolling list of every exercise, using the exercise row card described above. This is the default state on first launch.

#### 1b. Grouped mode (group by day)
The user organizes exercises into **workout days**. **There are no days by default** — the user creates as many as they want, and each day can hold as many exercises as they want.

- **Empty state** (no days created yet): a centered card (surface bg, radius 26px, shadow, padding 34px 18px 26px) with a `calendar_add_on` icon 44px in primary, heading "No days yet" (Baloo 2, 19px, weight 600), and body text "Create a day like "Day 1 · Push", then fill it with exercises." (Quicksand, 14px, weight 700, muted, line-height 1.45).
- **Day section** (one per day, margin-bottom 22px):
  - Header row (padding 0 2px 10px, gap 10px): [ordinal badge 30×30, radius ~28–40%, chipBg bg, number in Baloo 2 14px weight 700 chipText] [day name (Baloo 2, 18px, weight 600) + count line "{n} exercise(s)" (Quicksand, 12px, weight 700, muted)] [delete icon button 34×34, `delete` symbol 20px, muted].
  - The day's exercise rows — same card as flat mode, margin-bottom 11px.
  - **"Add exercises" button**: full width, 2px dashed border in border color, transparent bg, radius 26px, padding 14px, centered `add` icon 20px + label (Quicksand, 14px, weight 700, muted). Opens the Pick Exercises screen for that day. Always visible, including on empty days.
- **"New day" button** (below all day sections): full width, background primarySoft, text chipText, radius 26px, padding 16px, centered `calendar_add_on` icon 21px + "New day" (Baloo 2, 16px, weight 600). Creates a new day.
- Exercises **not** assigned to any day are **not** shown in grouped mode — they remain visible in flat mode and in the Pick Exercises screen.

**Day rules**
- New days are auto-named sequentially: "Day 1", "Day 2", … (name is a plain editable string in the data model; auto-naming is just the default).
- Deleting a day removes only the grouping: its exercises revert to unassigned (`day = null`) and are **not** deleted. Remaining days are **renumbered** so names stay sequential.
- An exercise belongs to at most **one** day.

### 2. Exercise Detail
- **Purpose**: See an exercise's stats and history; log a new entry.
- **Layout**: Top bar with back arrow only (padding 14px), scrollable body (padding 0 20px), fixed bottom "Add entry" button with a gradient fade behind it.
- **Hero (centered)**: 88×88 icon tile, border-radius 50%, tile bg color, Material Symbol 46px in tile fg. Name (Baloo 2, 27px, weight 600). Chips below (row, gap 7px): the body-part chip — pill, background chipBg, text chipText, 13px weight 700, padding 6px 14px, border-radius 100px. When the exercise is assigned to a day, a second chip of the same style follows it with a `calendar_today` icon 15px + the day's name; it is hidden when unassigned.
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

### 5. Pick Exercises (add exercises to a day)
- **Purpose**: Assign any number of existing exercises to a day, or create a new one directly into it.
- **Layout**: Back arrow top bar, scrollable body (padding 6px 20px), fixed bottom "Done" button.
- **Header**: eyebrow = the day's name (uppercase, 12px, weight 800, muted). Title "Add exercises" (Baloo 2, 28px, weight 600).
- **Selectable row** (one per exercise in the whole library): full-width button, surface bg, radius 18px, shadow, padding 12px 14px, margin-bottom 10px. Row = [icon tile 44×44, circular, pastel tile colors, symbol 24px] [name (Baloo 2, 16px, weight 600) + note line (Quicksand, 12px, weight 700, muted)] [check circle].
  - Note line text: "In this day" if assigned to this day; "In {other day name}" if assigned elsewhere; otherwise the exercise's body part.
  - Check circle: 26×26, radius 50%, 2px border. Selected → border + fill in primary with a white `check` symbol 17px. Unselected → border in border color, transparent fill, check hidden.
  - Tapping toggles membership: unassigned/other-day → this day; already in this day → unassigned.
- **"Create a new exercise" row**: dashed button (same styling as "Add exercises"), radius 18px, opens Add Exercise; the created exercise is assigned to this day automatically.
- **Done button** (fixed bottom): primary style, returns to the list.

### 6. Progress
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
- **Create exercise**: appends exercise (with body-part-derived icon), opens its detail. If it was started from the Pick Exercises screen, the new exercise's `day` is set to that day; from the FAB it is `null`.
- **Toggle grouping**: flips `grouped`; no data change. Consider persisting the user's last choice.
- **New day**: appends `{ id, name: "Day {n}" }`.
- **Delete day**: removes the day, sets `day = null` on its exercises, renumbers remaining day names sequentially. (No confirmation dialog in the prototype — add one if the codebase's conventions call for it.)
- **Toggle exercise in day**: sets `exercise.day` to `pickDayId`, or back to `null` if it was already in that day.
- **Transitions**: keep subtle. Toggle knob & track color animate 200ms. Everything else uses standard Material page transitions.
- No loading/error/network states in this prototype (local state only).

## State Management
Per-feature state (in the prototype it's a single component; in Flutter use a `ChangeNotifier`/`Provider`, `Riverpod`, or `Bloc` as the codebase prefers):
- `screen` (enum: list | detail | addEntry | addExercise | pick | progress) — or Flutter navigation instead.
- `selectedExerciseId: int`
- `grouped: bool = false` — list view mode (flat vs. grouped by day).
- `days: List<Day> = []` where `Day = { id:int, name:String }`. **Empty by default.**
- `pickDayId: int?` — the day currently being filled on the Pick Exercises screen; also used so a new exercise created from that screen lands in the right day.
- `exercises: List<Exercise>` where `Exercise = { id, name, bodyPart, icon, day: int?, entries: List<Entry> }` and `Entry = { reps:int, sets:int, failure:bool, date:String }`. `day` is the owning day's id, or `null` when unassigned (the default for new exercises created from the FAB).
- `newEntry: { reps:int=10, sets:int=3, failure:bool=false }` — draft for Add Entry.
- `newExercise: { name:String, bodyPart:String='Chest' }` — draft for Add Exercise.
- `weekly: List<{ day:String, volume:int }>` — Progress chart data.
- Derived: sessions (entries.length), bestReps (max reps), totalSets (sum sets), volume (reps×sets), chart heights (normalized %), weekly totals, day groups (exercises filtered by `day == d.id`).
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
Chevron `chevron_right`, back `arrow_back`, add `add`, stepper `remove`/`add`, failure `local_fire_department`, nav `home`/`bar_chart`, progress trophy `emoji_events`, empty state `note_add`, grouping toggle `calendar_view_week`/`view_agenda`, day create/empty `calendar_add_on`, day delete `delete`, day chip `calendar_today`, picker tick `check`.

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
