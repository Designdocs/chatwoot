#!/bin/sh
#
# Verify that this fork's local customizations survived an upstream merge and
# reached the built assets.
#
# These customizations fail silently: nothing errors when a merge drops them,
# the UI just quietly renders with upstream styling. This script turns that into
# a hard failure.
#
# Usage:
#   sh scripts/verify-customizations.sh                        # repo, after a merge
#   docker compose exec rails sh scripts/verify-customizations.sh   # running container
#
# Exits non-zero if any expected customization is missing.

set -u

PASS=0
FAIL=0
SKIP=0

if [ -t 1 ]; then
  G=$(printf '\033[32m'); R=$(printf '\033[31m'); Y=$(printf '\033[33m'); N=$(printf '\033[0m')
else
  G=''; R=''; Y=''; N=''
fi

# count FILE PATTERN -> occurrence count, or the word "missing"
count() {
  [ -f "$1" ] || { echo missing; return; }
  n=$(grep -cF -- "$2" "$1" 2>/dev/null) || n=0
  echo "$n"
}

# count_tree DIR PATTERN -> number of files containing PATTERN
count_tree() {
  [ -d "$1" ] || { echo missing; return; }
  grep -rlF -- "$2" "$1" 2>/dev/null | wc -l | tr -d ' '
}

# exact LABEL EXPECTED ACTUAL
exact() {
  if [ "$3" = "missing" ]; then
    SKIP=$((SKIP + 1)); printf '  %s--%s   %-44s %s\n' "$Y" "$N" "$1" 'file not present'
  elif [ "$2" = "$3" ]; then
    PASS=$((PASS + 1)); printf '  %sok%s   %-44s %s\n' "$G" "$N" "$1" "$3"
  else
    FAIL=$((FAIL + 1)); printf '  %sFAIL%s %-44s expected %s, got %s\n' "$R" "$N" "$1" "$2" "$3"
  fi
}

# atleast LABEL MIN ACTUAL
atleast() {
  if [ "$3" = "missing" ]; then
    SKIP=$((SKIP + 1)); printf '  %s--%s   %-44s %s\n' "$Y" "$N" "$1" 'not present'
  elif [ "$3" -ge "$2" ] 2>/dev/null; then
    PASS=$((PASS + 1)); printf '  %sok%s   %-44s %s\n' "$G" "$N" "$1" "$3"
  else
    FAIL=$((FAIL + 1)); printf '  %sFAIL%s %-44s expected >=%s, got %s\n' "$R" "$N" "$1" "$2" "$3"
  fi
}

SDK_SRC=app/javascript/sdk/sdk.js
THEME=app/javascript/widget/assets/scss/_theme_custom.scss
WOOT=app/javascript/widget/assets/scss/woot.scss
WIDGET_ZH=app/javascript/widget/i18n/locale/zh_CN.json
INBOX_ZH=app/javascript/dashboard/i18n/locale/zh_CN/inboxMgmt.json
BRANDING=app/javascript/shared/components/Branding.vue
WEBHOOK=app/listeners/webhook_listener.rb
CWAPP=lib/chatwoot_app.rb
SDK_BUILT=public/packs/js/sdk.js
PACKS=public/packs

[ -f VERSION_CW ] && printf 'Chatwoot %s\n' "$(cat VERSION_CW)"

echo
echo 'source customizations'
exact 'sdk.js  widget width 430px'     1 "$(count "$SDK_SRC" 'width: 430px')"
exact 'sdk.js  max-height 670px'       1 "$(count "$SDK_SRC" 'max-height: 670px')"
exact 'sdk.js  border #7d7d7e33'       2 "$(count "$SDK_SRC" '7d7d7e33')"
exact 'woot.scss imports theme_custom' 1 "$(count "$WOOT" 'theme_custom')"
atleast 'diy-border in _theme_custom'  1 "$(count "$THEME" 'diy-border')"
if [ -f "$THEME" ]; then
  atleast '_theme_custom.scss not truncated' 200 "$(wc -l < "$THEME" | tr -d ' ')"
else
  atleast '_theme_custom.scss not truncated' 200 missing
fi
exact 'widget zh_CN brand ArtstationX' 1 "$(count "$WIDGET_ZH" 'ArtstationX')"
exact 'inboxMgmt zh_CN 暂时离线'          1 "$(count "$INBOX_ZH" '暂时离线')"
exact 'Branding.vue de-branded'        0 "$(count "$BRANDING" 'widgetBrandURL')"
exact 'webhook_secret guard'           1 "$(count "$WEBHOOK" 'def webhook_secret')"
exact 'advanced_search decoupled'      1 "$(count "$CWAPP" 'regardless of enterprise status')"

echo
echo 'built assets'
exact 'built sdk.js  430px'            1 "$(count "$SDK_BUILT" '430px')"
exact 'built sdk.js  670px'            1 "$(count "$SDK_BUILT" '670px')"
exact 'built sdk.js  #7d7d7e33'        2 "$(count "$SDK_BUILT" '7d7d7e33')"
atleast 'diy-border compiled into packs' 1 "$(count_tree "$PACKS" 'diy-border')"

echo
printf 'passed %s   failed %s   skipped %s\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ] || { echo 'customizations are MISSING - do not ship this build'; exit 1; }
echo 'all customizations present'
