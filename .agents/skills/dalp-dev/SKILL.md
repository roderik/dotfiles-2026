---
name: dalp-dev
description: Manage DALP development workflows using ACP for remote-controllable agents, cmux workspaces, and DALP skills. All agents spawn via acpx enabling Telegram/Discord control. Triggers - work on PRD-xxx, start ticket, checkout PR, shepherd PR, cleanup workspace, status report, acp steer, acp status.
---

# DALP Dev Process — ACP-First

End-to-end development workflow using **ACP (Agent Client Protocol)** for remote-controllable agents.

## ACP vs Direct: What's Different

**Before:** `claude --dangerously-skip-permissions ...`
• Runs directly — you must type in terminal to interact

**After (ACP):** `acpx claude --cwd /path --label "ticket" ...`
• Runs via ACP backend — you can **control from Telegram** with `/acp` commands

## Quick Commands Reference

**Start new work (via ACP):**
• `wtn PRD-xxx` — Linear ticket → worktree + Claude Code via ACP
• `wtnx PRD-xxx` — Linear ticket → worktree + Codex via ACP
• `wtg PR-NUMBER` — Checkout PR as worktree (shows ACP spawn hint)
• `wtc BRANCH` — Create worktree (shows ACP spawn hint)

**Manage workspaces:**
• `wtl` — List worktrees and jump to one
• `wts` — Repair/setup cmux layout (lazygit + terminal)
• `wtd` — Delete worktree via fzf picker
• `wtr` — Remove current worktree and return to main

**Orchestration:**
• `wto` — Launch orchestrator via ACP (Telegram-controllable)

**ACP Control Commands (from Telegram):**
• `/acp status` — Show all ACP sessions and their status
• `/acp sessions` — List recent sessions with labels
• `/acp steer "what are you working on?"` — Send command to active session
• `/acp steer "status report"` — Get status from agent
• `/acp steer "focus on the type error"` — Redirect agent's attention
• `/acp close` — Close current ACP session

## Workflow Patterns — ACP Protocol

### Pattern 1: Start New Ticket (Linear + ACP)

**Trigger:** "Work on PRD-xxx"

**Steps:**
1. Check if workspace exists: `cmux list-workspaces`
2. If exists: focus it, check ACP session with `/acp status`
3. If not exists:
   - Run: `wtn PRD-xxx` (now spawns via `acpx claude --label PRD-xxx`)
   - This creates worktree + cmux layout + ACP-managed Claude
   - ACP session label = ticket ID (easy to identify)

**Telegram control after spawn:**
• `/acp status` — See the new session running
• `/acp steer "status"` — Ask what it's doing
• `/acp steer "pause and summarize"` — Get checkpoint

**DALP skill invoked:** `execute` — runs inside the ACP session

### Pattern 2: Remote Status Check

**Trigger:** "What's PR #6446 doing?" or "Status report"

**Steps:**
1. Find ACP session: `/acp sessions` — look for label containing "6446" or ticket ID
2. Steer the session: `/acp steer --session ID "status"` (natural language ok via ACP)
3. OR use cmux: `cmux read-screen --surface surface:N --lines 30`
4. Check CI: `gh run list --branch BRANCH --limit 3`
5. Check reviews: `bunx agent-reviews --unanswered`

**Key insight:** With ACP, you can ask from Telegram. For direct cmux control, read screens only — don't send raw text commands.

### Pattern 3: Shepherd PR to Merge

**Trigger:** "Shepherd PR #xxxx"

**Steps:**
1. Checkout PR: `wtg xxxx` (if not exists)
2. Focus the cmux workspace: `cmux focus-pane --pane pane:N`
3. **Send slash command to Claude:** `cmux send --workspace workspace:N --surface surface:M "/shepherd"`
4. Claude will run the shepherd skill internally to resolve reviews and drive to merge
5. Monitor progress via `cmux read-screen` or `/acp steer` if ACP-managed

**Key insight:** Use `/shepherd` slash command, not raw text instructions.

### Pattern 4: Cleanup with ACP Awareness

**Trigger:** "Cleanup" or "I'm done"

**Steps:**
1. Check ACP sessions: `/acp sessions`
2. Close relevant ACP session: `/acp close --session ID`
3. Check current workspace: `cmux identify --json`
4. Confirm it's a worktree (not main dalp)
5. Run `wtr` — removes worktree, returns to main

### Pattern 5: Spawn ACP Agent on Demand

**For existing worktrees without agents:**

```bash
# Spawn Claude via ACP in current directory
acpx claude --cwd (pwd) --label "PR-6446" "work on this PR"

# Spawn Codex via ACP
acpx codex --cwd (pwd) --label "ticket-name" "\$execute task"
```

**Then control from Telegram:**
• `/acp steer "status"`
• `/acp steer "run tests"`
• `/acp steer "commit and push"`

## ACP Control Interface

### From Telegram/Discord (primary)

All `/acp` commands work remotely:

| Command | Purpose |
|---------|---------|
| `/acp status` | Show backend health, active sessions |
| `/acp sessions` | List all sessions with labels and status |
| `/acp steer "message"` | Send instruction to active session |
| `/acp steer --session ID "msg"` | Target specific session |
| `/acp close` | Close current session |
| `/acp close --session ID` | Close specific session |
| `/acp doctor` | Check ACP backend health |

### From CLI (acpx)

```bash
# List sessions
acpx claude sessions list

# Show session details
acpx claude sessions show SESSION-ID

# Resume a session
acpx claude --resume SESSION-ID "continue where we left off"

# Named session (for easy reference)
acpx claude -s my-session-name "do something"
```

## DALP Skills Integration (inside ACP sessions)

The DALP repo has skills in `~/Development/dalp/.agents/skills/`:

### `/execute` — Implementation Lifecycle
**When triggered:** Inside ACP session via `wtn` or `wtnx`

**What it does:**
• Fetches Linear ticket state
• Plans implementation (delegates to `planner`)
• Implements with TDD
• Verifies completion (delegates to `verifier`)
• Creates PR, transitions ticket to In Review

**Remote control during execution:**
• `/acp steer "pause — show me the plan"`
• `/acp steer "skip tests for now, just implement"`
• `/acp steer "what's blocking you?"`

### `/shepherd` — Drive PR to Merge
**When triggered:** Inside ACP session

**Remote control:**
• `/acp steer "check CI status"`
• `/acp steer "fix the typecheck error"`
• `/acp steer "rebase on main"`

## Workspace Layout (cmux)

Standard layout created by `__wt_cmux_setup`:

```
┌─────────────────┬───────────┐
│                 │           │
│   ACP Agent     │  lazygit  │
│  (Claude/Codex) │  (right)  │
│                 │           │
├─────────────────┤           │
│                 │           │
│   Terminal      │           │
│  (bottom-left)  │           │
│                 │           │
└─────────────────┴───────────┘
```

**What's different with ACP:**
• The agent in the main pane is **ACP-managed**
• You can view its output in cmux
• **AND** control it remotely from Telegram via `/acp` commands
• Best of both worlds: local visibility + remote control

## Status Report Format — ACP-Aware

```
### {Workspace Name}
**Branch:** `{branch}`
**Path:** `{path}`
**ACP Session:** {label} (via `/acp sessions`)

**Agent:** {what it's doing — from /acp steer "status"}
**CI:** {status + brief error if failed}
**Reviews:** {count + brief summary}
```

**Telegram-friendly, no tables.**

## ACP-Specific Safety Rules

1. **Sessions persist across disconnects** — use `/acp close` to clean up
2. **Labels identify sessions** — use descriptive labels like "PRD-5388" or "PR-6446"
3. **Multiple sessions allowed** — up to `maxConcurrentSessions: 8` in config
4. **Session timeout** — default 120 minutes (`ttlMinutes` in config)
5. **Permission mode** — `approve-all` set for non-interactive ACP sessions

## Communicating with Claude Code in cmux

**CRITICAL RULE:** When sending commands to Claude Code via `cmux send`, use **only slash commands** (`/skill-name`), never raw text or natural language.

**Correct:**
• `cmux send --workspace workspace:N --surface surface:M "/shepherd"`
• `cmux send --workspace workspace:N --surface surface:M "/commit-push"`
• `cmux send --workspace workspace:N --surface surface:M "/execute PRD-xxx — title"`

**Incorrect:**
• `cmux send ... "fix the type error"` — Claude expects slash commands, not raw instructions
• `cmux send ... "check CI status"` — Use `/shepherd` instead

**Why:** The DALP repo has skills (execute, shepherd, commit-push, verify, etc.) that handle these workflows. Claude Code loads these skills and expects slash command invocations.

**Available DALP skills:**
• `/execute TICKET — TITLE` — Implementation lifecycle
• `/shepherd` — Drive PR to merge
• `/commit-push` — Stage, commit, and push changes
• `/verify` — Verify completion against spec

## Common Issues — ACP Edition

**Issue:** `/acp status` shows no sessions but agent is running
• Check if spawned directly (not via acpx) — direct spawn = no ACP control
• Fix: Use `wtn`/`wtnx` (they now use acpx) or spawn manually with `acpx`

**Issue:** `/acp steer` says "no active session"
• Run `/acp sessions` to see available sessions
• Use `/acp steer --session ID "message"` to target specific one

**Issue:** Session appears in `/acp sessions` but unresponsive
• Check cmux — agent may be waiting for input
• Try `/acp steer "continue"` or `/acp steer "^C"` (send Ctrl-C)

**Issue:** `acpx` command not found
• Install: `npm install -g acpx@latest`
• Or check OpenClaw plugin: `openclaw plugins install acpx`

## End-to-End ACP Workflow

User: "Work on PRD-5388"

1. **Terminal:** `wtn PRD-5388`
   • Creates worktree
   • Sets up cmux layout
   • Spawns: `acpx claude --label PRD-5388 --cwd /path "/execute ..."`
2. **Telegram:** `/acp sessions`
   • Shows: `PRD-5388 — running — /execute PRD-5388 ...`
3. **Later from phone:** `/acp steer "status"`
   • Agent replies with progress
4. **Check CI:** `/acp steer "run CI and report failures"`
5. **Done:** `/acp close` then `wtr`

**The power:** You can start work on your Mac, leave, and **control the same session from your phone** via Telegram.
