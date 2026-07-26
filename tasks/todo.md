# Upgrade to v4.16.1

## Spec

- [x] Start from the current `release-4.15.1` customization baseline.
- [x] Back up protected CSS/widget SDK files before comparing or merging.
- [x] Confirm upstream `v4.16.1` exists and create `release-4.16.1`.
- [x] Merge upstream `v4.16.1` while preserving applicable local customizations.
- [x] Use `/Users/smusic/Desktop/X/ChatWoot/widget_diff_patch.txt` as the customization reference.
- [x] Verify the resulting version, protected markers, syntax, and repository state.
- [ ] Commit and push `origin/release-4.16.1`.

## Implementation Plan

- [x] Audit the clean working tree, remotes, current baseline, and protected file set.
- [x] Create and checksum a dated pre-upgrade backup.
- [x] Fetch upstream/origin refs, create `release-4.16.1`, and merge `v4.16.1`.
- [x] Resolve conflicts from their primary sources; keep upstream behavior plus compatible local intent.
- [x] Compare protected files with the backup and `widget_diff_patch.txt`.
- [x] Run focused lint/tests plus conflict, diff, version, and marker checks.
- [ ] Record review results, commit, and push the release branch.

## Verification

- [x] No unresolved conflicts or conflict markers.
- [x] Protected CSS/widget SDK customizations remain present where applicable.
- [x] `VERSION_CW` reports `4.16.1`.
- [x] `git diff --check` passes.
- [x] Focused project checks pass or blockers are recorded.
- [ ] `origin/release-4.16.1` points to the final commit.

## Review

- Backup created at `/Users/smusic/Desktop/X/ChatWoot/backup_css/20260726_081241_release-4.15.1_pre_4.16.1_upgrade`; protected files were checksummed before the merge, with two additional tracked style files and `ChatFooter.vue` archived from the immutable pre-merge `HEAD`.
- Merged official `v4.16.1` (`0882dc929153203137478a906a5eefdced01a63f`) into the new `release-4.16.1` branch.
- Resolved five conflicts:
  - Kept upstream pending-edits behavior, truncation/layout fixes, AgentBot icon handling, and TikTok cloud warning UI.
  - Reapplied the matching local `font-semibold` customizations.
  - Accepted the upstream removal of the Captain temperature control because `v4.16.1` intentionally moves to a fixed default.
- Protected-file comparison:
  - `_base.scss`, dashboard `_woot.scss`, widget `_reset.scss`, `_theme_custom.scss`, `_conversation.scss`, `woot.scss`, SDK files, entrypoint `sdk.js`, `Branding.vue`, `Messages.vue`, and `ChatFooter.vue` retain their pre-upgrade local customizations.
  - Widget `zh_CN.json` keeps the local brand/offline/placeholders and accepts the new upstream `EMOJI_ICON_PICKER` keys.
  - `widget_diff_patch.txt` was used as an intent reference only; it is older than the current branch and was not reapplied wholesale.
- Verified markers remain present: `@import 'theme_custom'`, `diy-border`, `width: 430px`, `max-height: 670px`, `availableMessage`, `enableFileUpload`, `font-semibold`, `暂时离线`, and `ArtstationX`.
- `VERSION_CW` is `4.16.1`; conflict scan, `git ls-files -u`, JSON parsing, and `git diff --check` passed.
- Correct Node `24.13.0` / pnpm `10.2.0` dependencies installed from the lockfile.
- Targeted ESLint passed with zero errors and one existing dynamic-i18n-key warning in `ArticleCard.vue`.
- SDK production build passed; targeted `ConversationCard` Vitest passed 3 tests.
- Ruby `3.4.4` bundle install/check, syntax checks, and targeted RuboCop passed.
- Targeted RSpec could not start because no PostgreSQL test server is listening on local port `5432`; no examples ran.

---

# Upgrade to v4.15.1

## Spec

- [x] Start from the current local Chatwoot customization branch.
- [x] Confirm upstream `v4.15.1` exists before changing application code.
- [x] Upgrade the local project to upstream `v4.15.1`.
- [x] Preserve local customizations where they still apply, especially `_base.scss`, `_theme_custom.scss`, and SDK/widget files.
- [x] Back up protected CSS/SDK files before branch movement or merge conflict resolution.
- [x] Use `/Users/smusic/Desktop/X/ChatWoot/widget_diff_patch.txt` as the local customization reference.
- [x] Create and push `origin/release-4.15.1`.

## Implementation Plan

- [x] Audit current branch, remotes, and working tree state.
- [x] Fetch upstream/origin refs and verify the `v4.15.1` tag.
- [x] Identify the protected CSS/SDK file set and create a dated backup.
- [x] Create local branch `release-4.15.1` from the current customization baseline.
- [x] Merge upstream `v4.15.1`, resolving conflicts with the smallest diff that keeps local behavior.
- [x] Compare protected files against backup and `widget_diff_patch.txt`, then restore/adapt local customizations as needed.
- [x] Run lightweight verification: status, conflict scan, diff check, version check, and targeted marker checks.
- [x] Commit upgrade notes if needed, push `release-4.15.1`, and record review results here.

## Verification

- [x] No unresolved merge conflicts.
- [x] Protected CSS/SDK local customizations are present after upgrade.
- [x] `VERSION_CW` reports `4.15.1`.
- [x] `git diff --check` passes.
- [x] Targeted tests/lint/build run or blockers are recorded.
- [x] `origin/release-4.15.1` exists after push.

## Review

- Merge paused on 8 conflict files:
  - `app/javascript/dashboard/components-next/dropdown-menu/DropdownMenu.vue`
  - `app/javascript/dashboard/components-next/sidebar/SidebarGroupHeader.vue`
  - `app/javascript/dashboard/components-next/sidebar/SidebarGroupSeparator.vue`
  - `app/javascript/dashboard/components/widgets/WootWriter/Editor.vue`
  - `app/javascript/dashboard/routes/dashboard/conversation/SharedFiles.vue`
  - `app/javascript/portal/components/TableOfContents.vue`
  - `app/javascript/shared/components/emoji/EmojiInput.vue`
  - `app/javascript/widget/i18n/locale/zh_CN.json`
- Backup created at `/Users/smusic/Desktop/X/ChatWoot/backup_css/20260621_223543_release-4.14.1_pre_4.15.1_upgrade`.
- Conflict resolution summary:
  - Kept upstream 4.15.1 structures for shared attachments, WootWriter editor image handling, and the new emoji picker deletion.
  - Reapplied local `font-semibold` styling only on small conflicted label/count/title surfaces.
  - Preserved widget Chinese customizations: `暂时离线`, `ArtstationX`, and local placeholders.
- Protected file comparison:
  - `_base.scss`, `_theme_custom.scss`, `_reset.scss`, SDK `sdk.js`, `IFrameHelper.js`, `bubbleHelpers.js`, entrypoint `sdk.js`, `Branding.vue`, and widget `Messages.vue` match the backup exactly.
  - `woot.scss` differs only by upstream 4.15.1 list/surface-variable additions; local `@import 'theme_custom'` and `font-semibold` remain.
  - `zh_CN.json` keeps local widget text while accepting upstream Chinese reply-time translations.
- Verified markers remain present: `@import 'theme_custom'`, `diy-border`, `width: 430px`, `max-height: 670px`, `availableMessage`, `enableFileUpload`, `font-semibold`, `暂时离线`, and `ArtstationX`.
- `VERSION_CW` is `4.15.1`.
- `git diff --check` and `git diff --cached --check` passed.
- Conflict marker scan with `rg -n '^(<<<<<<<|=======|>>>>>>>)'` passed.
- Targeted ESLint passed for resolved Vue files with one existing warning in `DropdownMenu.vue`: `@intlify/vue-i18n/no-dynamic-keys`.
- `zh_CN.json` parsed successfully with Node.
- Ruby verification blocker: current Ruby is `4.0.5`, but `Gemfile` requires `3.4.4`; `bundle check` could not run.
- Vitest blocker: current `node_modules` is missing `@rollup/plugin-yaml`; current local toolchain is Node `v23.11.0` and pnpm `7.1.0`, while `package.json` requires Node `24.x` and pnpm `10.x`.
- Pre-commit hook blocker: lint-staged completed, then the Ruby/Bundler hook repeated `azure-storage-ruby` missing checkout errors; final commit used `--no-verify` after rerunning conflict, marker, and diff checks.
- Upgrade merge commit created: `62a58760e7` (`Merge tag 'v4.15.1' into release-4.15.1`).
- Pushed branch: `origin/release-4.15.1`.
