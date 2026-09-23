# YAM Agent Guide

`yam` is a local-first nutrition tracker for Android and iOS, with macOS and Linux as supported desktop platforms. Its core promise is fast, simple daily food logging that works without an account or network.

## Read Order And Persistent Memory

Use the following sources in order when starting a task:

1. The current user request.
2. Relevant accepted ADRs in `docs/adr/`.
3. `agents/PROJECT_BLUEPRINT.md` for product and architecture requirements.
4. `agents/PROJECT_STATE.md` for the compact current handoff.
5. The relevant implementation and tests.

Do not read the entire blueprint by default. Read the sections that concern the task. `PROJECT_STATE.md` must remain a short, current snapshot; Git history is the detailed chronological record.

At the end of every meaningful task, update `agents/PROJECT_STATE.md` with:

- what is now implemented and the files that matter;
- any decision made, with an ADR link when applicable;
- verification that was run and its result;
- the single most specific next step and blockers.

Remove obsolete status rather than appending a session diary. Keep the file under roughly 250 lines and record only facts useful to the next agent. Never store secrets, tokens, personal data, or machine-specific paths there.

Create `docs/adr/NNNN-short-title.md` before or with a decision that changes product behavior, persisted data, architecture boundaries, dependency strategy, design tokens, or performance policy. An ADR supersedes a conflicting older ADR or blueprint detail only when it explicitly says so.

## Design References

Approved visual references live under `agents/design/`.

For tasks that create or modify UI:

1. Read the relevant accepted design ADRs first.
2. Inspect the HTML reference for the screen being implemented.
3. Inspect `agents/design/yam_components_2.html` for shared patterns and states
   not specified by the screen reference.
4. Inspect existing Flutter theme tokens and reusable UI components.
5. Inspect the current feature implementation and tests.

The HTML files are visual specifications, not production code and not architectural examples.

Do not copy:
- Tailwind/CSS structure;
- arbitrary inline colours or spacing values;
- fake OS/status/navigation chrome;
- browser-specific behaviour;
- accidental inconsistencies between generated HTML files.

When a screen HTML reference conflicts with an accepted ADR or canonical
Flutter semantic tokens, the ADR/tokens win. For screen-level composition,
density, spacing intent, and contextual visual geometry, the screen reference
wins over `yam_components_2.html`.

Do not redesign an approved reference unless the user explicitly asks for a design change.

Reuse existing YAM components and semantic theme tokens. If a visual pattern is repeated across approved screens and no reusable Flutter component exists yet, promote it into the shared UI layer before duplicating it in features.

## Product Priorities

Use this ordering for trade-offs:

1. Local-first operation and stable user history.
2. Fast, low-friction daily logging.
3. Correct, testable nutrition calculations.
4. Clear, accessible, adaptive UI.
5. Future sync without making a backend necessary now.

Do not add a feature unless it makes tracking faster, simpler, or more accurate. Do not build network, account, sync, barcode, or AI functionality ahead of the local MVP slice defined in the blueprint.

## Architecture And Data

- Use feature-first organisation. Keep `lib/app`, `lib/core`, `lib/domain`, and `lib/features` focused; do not introduce a layer or interface until it has a present use.
- The intended foundations are Riverpod, `go_router`, and Drift/SQLite. Add a dependency only for a concrete requirement and keep its usage behind the smallest useful boundary.
- SQLite is the source of truth. Remote providers are optional, asynchronous enrichments; they must not block local reads, search, or diary input.
- Keep business logic, numeric calculations, query composition, and conversions outside widgets. Widgets render state and dispatch intent.
- New persisted user entities must be sync-ready: UUID v7 public IDs, creation/update metadata, `deviceId`, and soft deletion where the blueprint requires it. Make schema changes only through tested Drift migrations.
- Diary entries store nutrition and naming snapshots. Changing a food must never rewrite historical intake.
- Diary days are local calendar dates. Store instants separately and do not derive a diary day from UTC.
- Store canonical units internally: grams, milliliters, kilograms, and kcal. Convert only at the UI boundary. Never assume that milliliters equal grams.
- Preserve stored numeric precision; presentation rounding must not be written back to storage.

## Flutter, UI, And UX

- Follow the repository lints and idiomatic modern Dart. Prefer small immutable models, explicit types where they improve clarity, `const` widgets, and focused providers.
- Put reusable visual tokens in `lib/app/theme` and reuse them. Colours, typography, spacing, shape, elevation, and motion must not be duplicated as ad-hoc literals across features.
- Add a component to `lib/core/ui` only after a real repeated need. Do not create a generic design system for one screen. The approved screen set now constitutes repeated need for shared YAM
form, navigation, feedback, list, and nutrition primitives.
Do not wait for duplicate feature implementations before extracting
an already-established repeated pattern.
- Define animation timings and curves centrally before introducing product animation. Motion must be short, purposeful, interruptible where needed, and respect `MediaQuery.disableAnimations` or accessibility settings. Never use animation to hide loading or slow input.
- Design for touch, keyboard, mouse, screen readers, text scaling, light/dark/system themes, portrait/landscape, narrow phones, tablets, and wide desktop windows. Use constraints and `LayoutBuilder`; avoid fragile fixed screen sizes.
- Navigation must adapt rather than stretch a phone layout. The expected direction is bottom navigation on compact layouts and a rail/sidebar on wider layouts.
- Keep primary diary actions visible and quick. A frequently used food should be addable in one tap using its remembered portion.

## Localisation

- Localise from the first app shell using Flutter's generated l10n (`gen-l10n`) and ARB files under `lib/l10n/`.
- UI-visible strings include labels, errors, empty states, dialogs, snackbars, semantic labels, plural forms, dates, and units. Do not hardcode them in widgets, providers, or routes.
- Support Russian and English initially. Use locale-aware formatting and keep generated localisation output unedited.
- Food names from data providers are data, not translated UI copy; preserve source/localised food names as the model permits.

## Performance And Reliability

- Do not start I/O, database work, sorting, filtering, parsing, or network requests from `build` methods.
- Scope provider watches to the smallest state that a widget needs. Use lazy lists/slivers for unbounded collections and stable keys for mutable rows.
- Index database queries that serve diary, search, and history views. Move expensive database, import/export, image, and aggregation work off the UI isolate when its cost warrants it.
- Local data renders first. Network failures must be recoverable and must not prevent local tracking.
- Measure or profile before adding caching, isolates, abstractions, or performance packages.

## Verification And Delivery

- Format edited Dart files with `dart format`.
- Run `flutter analyze` for edited Dart code. For visual/prototype UI iterations, use manual acceptance as the primary check: do not add tests or goldens for every UI tweak and do not run the full `flutter test` suite by default. Keep existing tests consistent with changed behaviour. Run focused tests when requested or when necessary to validate nontrivial behaviour; reserve the full suite for changes to shared business logic, persistence, or an explicit request.
- Add unit tests for calculations, conversions, persistence migrations, and derived state when those features are implemented. Add widget or golden tests for important UI flows when they become stable and there is a concrete verification need.
- Inspect the final diff. Do not modify unrelated worktree changes and do not commit unless asked.
- Write identifiers and code in English. Keep project documentation in Russian unless the existing document establishes another language.
