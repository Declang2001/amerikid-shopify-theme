#!/usr/bin/env bash
# PreToolUse(Bash) guard for the AmeriKid theme repo.
#
# Permission rules in settings.local.json are PREFIX-match only, so they cannot
# express "a push that contains --allow-live" — the flag sits mid-command.
# This hook inspects the whole command string and denies the shapes that have
# actually damaged this store, or that the repo docs forbid.
#
# Reads PreToolUse JSON on stdin. Emits a deny decision, or exits 0 silently.
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)" || exit 0
[ -z "$cmd" ] && exit 0
case "$cmd" in *shopify*) ;; *) exit 0 ;; esac

deny() {
  jq -cn --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

has() { printf '%s' "$cmd" | grep -Eq "$1"; }

LIVE_ID='186464731416'
DARK_ID='184615043352'

# 1. Publishing is owner-only and manual in Admin.
has 'shopify[[:space:]]+theme[[:space:]]+publish' &&
  deny "BLOCKED: 'shopify theme publish' is owner-only and must be done manually in Shopify Admin. See AGENTS.md > Deploy Guardrails."

# 2. Theme deletion.
has 'shopify[[:space:]]+theme[[:space:]]+delete' &&
  deny "BLOCKED: 'shopify theme delete' is never run by an agent."

# 3. theme dev --theme : hot-syncs local saves AND git checkouts to the target.
#    This reverted the live Archive template on 2026-06-18 (docs/change-log.md:15).
has 'shopify[[:space:]]+theme[[:space:]]+dev' && has '(^|[[:space:]])--theme([[:space:]]|=)' &&
  deny "BLOCKED: 'shopify theme dev --theme' hot-syncs local saves AND git checkouts to the target theme. It reverted the live Archive template on 2026-06-18. Use: shopify theme dev --store iacxyv-w5.myshopify.com (no --theme)."

# 4. Any push that can write to the published theme.
has 'shopify[[:space:]]+theme[[:space:]]+push' && has '(^|[[:space:]])--(allow-live|live)([[:space:]]|=|$)' &&
  deny "BLOCKED: push with --allow-live/--live writes to the PUBLISHED storefront. The drop theme is unpublished; target it with --theme <NEW_ID> instead."

# 5. Never target the live notebook theme or the preserved dark theme.
has 'shopify[[:space:]]+theme' && has "(^|[[:space:]])--theme([[:space:]]|=)+${LIVE_ID}" &&
  deny "BLOCKED: ${LIVE_ID} is the LIVE notebook theme. The drop must never target it."
has 'shopify[[:space:]]+theme' && has "(^|[[:space:]])--theme([[:space:]]|=)+${DARK_ID}" &&
  deny "BLOCKED: ${DARK_ID} is the preserved dark theme and must stay byte-unchanged (docs/source-of-truth.md:42)."

# 6. Unscoped push: no --only means the entire working tree ships. There is no .shopifyignore.
has 'shopify[[:space:]]+theme[[:space:]]+push' && ! has '(^|[[:space:]])--only([[:space:]]|=)' && ! has '(^|[[:space:]])--unpublished([[:space:]]|=|$)' &&
  deny "BLOCKED: 'shopify theme push' without --only ships the ENTIRE working tree (there is no .shopifyignore). Use scoped --only pushes, or --unpublished to create a new theme."

# 7. settings_data.json is merchant-owned and Admin-overwritable.
has 'shopify[[:space:]]+theme[[:space:]]+push' && has 'config/settings_data\.json' &&
  deny "BLOCKED: pushing config/settings_data.json clobbers 123 merchant settings, 10 colour schemes and 3 app embeds."

exit 0
