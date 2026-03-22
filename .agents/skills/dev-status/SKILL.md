---
name: dev-status
description: Generate development workflow status reports for Telegram. Use when the user asks for a status report on development work across multiple cmux workspaces, GitHub PRs, CI status, or agent activity. This skill formats output specifically for Telegram (no markdown tables, bullet lists only, clean and concise).
---

# Dev Status

Generate clean, Telegram-friendly status reports for development workflows.

## Report Format

Each workspace gets exactly 4 sections in this fixed order:

```
### {PR/Workspace Name}
**Branch:** `{branch-name}`
**Path:** `{local-path}`

**Agent:** {claude/codex status — what it's doing right now}
**CI:** {PASS/FAIL/UNKNOWN — which job failed + brief error}
**Reviews:** {count + brief summary of what needs attention}
```

## Rules

1. **NO TABLES** — Telegram doesn't render them well. Use bullet lists only.
2. **NO HEADERS inside sections** — Keep it flat.
3. **Use emojis sparingly:** ✅ ❌ ⚠️ ⏳
4. **Keep CI errors to 1 line** — truncate with "..." if needed.
5. **Keep review summaries to 1 line** — "12 Copilot comments on types/SQL" is enough.

## Information Sources

Gather status from:
- `cmux tree --all` — workspace and surface layout
- `cmux read-screen --surface surface:N --lines 30` — what agents are doing
- `gh run list --repo settlemint/dalp --branch {branch} --limit 3` — CI status
- `gh run view {run-id} --json jobs` — failed job details
- `bunx agent-reviews --unanswered` — pending review comments

## Quick Action Summary

End with a prioritized list (P1/P2/P3) of what needs attention.

Format:
```
**P1** — {workspace}: {action}
**P2** — {workspace}: {action}
```

## Example Output

```
### PR #6446 — PriceResolver addon
**Branch:** feat/price-resolver-experimental
**Path:** ~/Development/dalp.feat-price-resolver-experimental

**Agent:** Claude Code — PriceResolver implementation (feed + claim fallback) ⏳ Active
**CI:** ❌ FAILED — Unit Tests: test_Initialize_Reverts_ZeroFeedsDirectory failed
**Reviews:** 19 unanswered — 12 Copilot comments on types/SQL/performance

### PR #6450 — graph-node v0.42.0
**Branch:** renovate/non-major-updates
**Path:** ~/Development/dalp.renovate-non-major-updates

**Agent:** Claude Code — All review threads resolved ✅ Done
**CI:** ✅ PASSED
**Reviews:** 2 unanswered — chatgpt-codex-connector + renovate notification
```
