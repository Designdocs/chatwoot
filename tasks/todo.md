# Upgrade to v4.14.1

## Spec

- [x] Confirm upstream `v4.14.1` exists before changing local code.
- [x] Upgrade the local Chatwoot repo from the current `release-4.14.0` customization baseline to upstream `v4.14.1`.
- [x] Preserve existing local behavior unless upstream changes require an intentional compatibility adjustment.
- [x] Back up CSS- and widget-related custom files before branch movement, with explicit focus on `_base.scss`, `_theme_custom.scss`, SDK files, and widget SCSS.
- [x] Use `/Users/smusic/Desktop/X/ChatWoot/widget_diff_patch.txt` as the reference for required local widget/dashboard styling details.
- [x] Keep existing local customization commits from `release-4.14.0` where they still apply cleanly.
- [x] Create and push a new branch named `release-4.14.1` to `origin`.

## Implementation Plan

- [x] Audit current local branch, remotes, and upstream tag availability.
- [x] Identify local commits on top of upstream `v4.14.0` and list protected custom files.
- [x] Back up the targeted CSS/SDK files to a dated folder before any branch movement or conflict resolution.
- [x] Fetch upstream `v4.14.1`, create `release-4.14.1`, and bring the branch forward with a low-risk history strategy.
- [x] Reconcile conflicts and reapply or adapt local customizations with direct comparison against the backup and `widget_diff_patch.txt`.
- [x] Run targeted verification for diff hygiene and preserved customization markers.
- [x] Commit the result, push `origin/release-4.14.1`, and record review notes here.

## Verification

- [x] Confirm the protected CSS/SDK files still contain the expected local customizations after the upgrade.
- [x] Confirm markers from `widget_diff_patch.txt` remain present where still relevant.
- [x] Confirm there are no unresolved conflicts or malformed patches with `git diff --check`.
- [x] Run available targeted test/lint checks or clearly record why they could not run.
- [x] Confirm the new branch exists locally and on `origin`.

## Review

- Backup created at `/Users/smusic/Desktop/X/ChatWoot/backup_css/20260529_222723_release-4.14.0_pre_4.14.1_upgrade`.
- Upgrade strategy used: branch from local `release-4.14.0`, merge upstream tag `v4.14.1`, then resolve conflicts.
- Conflict resolution summary:
  - Kept upstream `contacts/initiateCall` because 4.14.1 now has multiple call entry points that depend on it.
  - Accepted upstream migration from `app/javascript/dashboard/components/widgets/FloatingCallWidget.vue` to `app/javascript/dashboard/components-next/call/FloatingCallWidget.vue`.
  - Reapplied local `font-semibold` styling in conflicted Vue/SCSS areas.
- Protected file comparison:
  - `_base.scss`, widget `_theme_custom.scss`, `_reset.scss`, `_conversation.scss`, dashboard `_woot.scss`, SDK `IFrameHelper.js`, SDK `bubbleHelpers.js`, SDK `sdk.js`, and entrypoint `sdk.js` match the backup exactly.
  - `app/javascript/widget/assets/scss/woot.scss` only differs by upstream 4.14.1 select color-scheme additions; local `font-semibold` customization remains.
- Verified required markers are present: `font-semibold`, `diy-border`, `woot-widget-holder`, and `暂时离线`.
- `VERSION_CW` is `4.14.1`.
- `git diff --cached --check` passed.
- Ruby tests could not run because this machine is using system Ruby `2.6.10` and is missing Bundler `2.5.16`.
- Targeted Vitest command could not run because the current Node/pnpm environment is below the 4.14.1 engine requirement (`Node 24.x`, `pnpm 10.x`), and direct local Vitest startup fails because existing `node_modules` is missing `@rollup/plugin-yaml`.
- Commit created: `4469104202` (`Merge tag 'v4.14.1' into release-4.14.1`).
- Pushed branch: `origin/release-4.14.1`.
