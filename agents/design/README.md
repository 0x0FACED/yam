# YAM Design References

This directory contains approved visual references produced during
the product design phase.

They define visual intent and screen composition.
They are not production HTML and must not be translated literally.

## Priority

For visual decisions:

1. Accepted design ADRs
2. Canonical Flutter theme/design tokens
3. Approved screen HTML for screen composition, density and contextual geometry
4. `yam_components_2.html` for shared patterns and unspecified states
5. Existing implementation
6. Agent judgment

If references disagree, do not silently average them.

## Global rules

YAM is:
- calm;
- compact;
- information-dense;
- utility-first;
- warm rather than clinical.

Avoid:
- gradients;
- glassmorphism;
- decorative nested cards;
- dashboard styling where a simple form/list works;
- arbitrary colours;
- visual noise.

Purple is the application accent.

Nutrition colours:
- protein: orange;
- fat: lime;
- carbohydrates: cyan.

Nutrition colours are semantic and must not be reused for unrelated
goal/status states.

Both light and dark themes are first-class.

## HTML reference caveats

Generated HTML may contain:
- incorrect raw colour values;
- duplicated icons;
- browser/native controls;
- fake phone chrome;
- implementation-specific Tailwind classes.

Those details are not authoritative.

Match visual hierarchy, spacing, density, composition and interaction
intent, then implement idiomatically in Flutter.

Compact visual controls may keep a larger transparent or low-emphasis hit area.
Do not enlarge their visible surface solely to satisfy the 44 logical px touch
target.

## Screen references

- `yam_diary.html` — main daily diary
- `yam_food_search.html` — food search and contextual suggestions
- `yam_add_food.html` — quantity/add flow
- `yam_edit_diary_entry.html` — edit existing entry
- `yam_createcproduct.html` — custom food creation
- `yam_statistics.html` — statistics
- `yam_settings.html` — settings/list pattern
- `yam_goals.html` — nutrition and weight goals
- `yam_onboarding_1.html`
- `yam_onboarding_2.html`
- `yam_onboarding_3.html`

## Interaction rules not visible in static HTML

Static HTML does not define product behaviour.
Use ADRs and PROJECT_BLUEPRINT for behaviour and persistence semantics.
