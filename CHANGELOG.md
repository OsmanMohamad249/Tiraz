# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- 2025-11-17 — CI: Stabilized Smoke E2E for Measurements (PR #76)
  - Moved DB persistence verification to run immediately after creating a measurement
    (before deletion) to avoid checking for a deleted record.
  - Ensured `docker compose exec` uses the generated `.ci/.ci.env` so `SECRET_KEY`
    and `TEST_EMAIL` are available inside containers during the check.
  - Result: Smoke E2E tests passed and PR #76 (migrations + models) was merged.

*(Short summary added by automation for changelog / audit purposes.)*
