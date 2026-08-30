# AI Agent Instructions (AGENTS.md)

## Core Mandate
- **Preservation-First:** You must prioritize preserving the exact visual output, interactive behavior, and animation personality of this storefront over code cleanliness.
- **Do Not Change Look/Behavior:** Never alter the aesthetic or functional behavior without explicit user approval.
- **Read First:** Always read this `AGENTS.md` file and `docs/source-of-truth.md` before making any plan or change.

## Working Rules
- **Fragile Systems:** Treat custom animation logic, starfield canvases, and brand-specific overrides (like hardcoded Impact fonts) as highly fragile.
- **Documentation:** You must update the relevant markdown files in the `docs/` folder after every approved change.
- **Deletion Policy:** Do not delete files that appear to be duplicates or backups without definitively proving they are unused in the active live theme structure.
- **Risk Assessment:** Always explain the risk level to the user before modifying any fragile files.
- **Minimal Impact:** Prefer the smallest safe change over broad refactoring.
- **Continuity:** Keep future prompts and handoffs aligned with these rules so the next AI tool or human developer has clear context.
## Deploy Guardrails (authoritative — hoisted from docs/known-fragile-areas.md:6)

These are enforced at the tool layer by `scripts/guard-shopify.sh`
(a PreToolUse hook registered in `.claude/settings.local.json`), not just by prose.

- **NEVER run `shopify theme dev --theme <id>`.** It hot-syncs local saves **and git
  checkouts** to the target theme. On 2026-06-18 a rogue instance did exactly this and
  reverted the live Archive template (`docs/change-log.md:15`).
  Safe preview: `shopify theme dev --store iacxyv-w5.myshopify.com` with **no** `--theme`.
- **Never run `shopify theme publish` or `shopify theme delete`.** Publishing is
  owner-only and manual, in Shopify Admin.
- **Only sanctioned push shape:**
  `shopify theme push --theme <ID> --nodelete --only <file> [--only <file>...]`
  A push without `--only` ships the entire working tree — there is no `.shopifyignore`.
- **Never push `config/settings_data.json`.** 123 merchant settings, 10 colour schemes
  and 3 app embeds; it is auto-generated and Admin-overwritable.
- **Theme IDs:**
  - `186464731416` — **LIVE** notebook theme. Never a target for drop work.
  - `184615043352` — preserved dark theme. Must stay **byte-unchanged**.
  - `185910067480` — development lane.
- Before any branch switch, confirm no `shopify theme dev` server is running.
