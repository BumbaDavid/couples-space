# ADR-007: Peachy design system

**Date:** 2026-07-11
**Status:** Accepted

## Decision

The app uses the **Peachy** visual direction for all screens. Design tokens (colors,
typography, shadows) are centralised in `lib/core/theme/theme.dart` as `AppColors` and
`AppTheme`. The design handoff lives at
`docs/design/design_handoff_workout_tracker/README.md`.

## Why

The Peachy palette was chosen during the workout-tracker feature design phase. It is a
cute & cozy, pastel, Material-style aesthetic that fits the couples / personal-use
context of the app. Rather than applying it only to the new feature, the decision was
made to adopt it app-wide so existing screens (auth, notes, profile) are restyled to
match when they are touched.

## Key tokens

| Token | Value | Use |
|-------|-------|-----|
| `AppColors.bg` | `#FBF3EC` | Scaffold background |
| `AppColors.surface` | `#FFFFFF` | Cards |
| `AppColors.primary` | `#EF9270` | Coral — buttons, FAB, active nav |
| `AppColors.primarySoft` | `#FBE0D3` | Tinted containers |
| `AppColors.text` | `#4B3A33` | Body text |
| `AppColors.muted` | `#A99184` | Secondary text, icons |
| `AppColors.chipBg` / `chipText` | `#F6E7DC` / `#9A6B4E` | Filter chips |
| `AppColors.border` | `#F0E4DA` | Dividers, outlines |
| `AppColors.failText` / `failBg` | `#C25B3A` / `#FBE0D3` | Failure/error states |
| `AppColors.tilePalette[i % 5]` | 5 pastels | Exercise icon tiles (cycled) |
| `AppTheme.cardShadow` | `0 8px 22px rgba(180,120,90,0.13)` | Cards |
| `AppTheme.buttonShadow` | `0 10px 22px rgba(224,122,84,0.32)` | Primary buttons, FAB |

**Typography:** Baloo 2 (headings/titles, weight 600–700) + Quicksand (body/labels,
weight 700–800). Both via `google_fonts`.

**Radii:** cards 26px · small cards/fields 18px · primary buttons 18px · FAB 22px ·
chips/pills 100px · icon tiles circular.

## Rules

- **Never use raw hex in UI code.** Always reference `AppColors.*`.
- `AppTheme.light()` wires all component themes (cards, buttons, FAB, chips, inputs,
  bottom nav). Use `Theme.of(context)` first; reach for `AppColors` directly only for
  properties the theme doesn't cover (e.g. custom `BoxDecoration` shadows).
- Dark mode exists in `AppTheme.dark()` but has no Peachy-specific design yet — it uses
  a seeded scheme from the primary coral.

## Trade-offs

- Google Fonts requires a network fetch on first launch (fonts are cached after that).
  Bundling the `.ttf` files in `pubspec.yaml` assets would remove the dependency on
  network availability, but `google_fonts` is simpler for now.
- Existing screens still use the old pink seed colour until they are restyled. This is
  intentional — screens are updated as each is touched, not all at once.
