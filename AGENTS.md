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