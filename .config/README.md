# Dotfiles

Managed with [yadm](https://yadm.io). Clone on a new machine:

```shell
yadm clone <repo-url>
yadm bootstrap
```

---

## Tools

### Terminal

#### [cmux](https://cmux.com)

Native macOS terminal built on libghostty. Vertical tabs, notification rings for agents, split panes, and a socket API for automation.

```shell
# Download DMG
open https://github.com/manaflow-ai/cmux/releases/latest/download/cmux-macos.dmg
```

Config: `~/.config/ghostty/config` (cmux reads Ghostty keybindings)

#### [Ghostty](https://ghostty.org)

GPU-accelerated terminal emulator. cmux uses libghostty under the hood, but standalone Ghostty is also installed.

```shell
brew install --cask ghostty
```

Config: `~/.config/ghostty/config`

---

### Shell

#### [Fish](https://fishshell.com)

Primary shell. Plugins managed via [Fisher](https://github.com/jorgebucaran/fisher).

```shell
brew install fish
# Set as default shell
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Install Fisher + plugins from fish_plugins
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher update
```

Config: `~/.config/fish/`
Plugins: tide, autopair, puffer, sponge, vesper-theme (listed in `fish_plugins`)

---

### Claude Code Plugins

#### [RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk)

CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. Hooks into Claude Code transparently.

```shell
brew install rtk
rtk init -g          # Install hook + RTK.md
# Verify
rtk --version
rtk gain             # Show token savings
```

Config: `~/.claude/RTK.md` (auto-installed by `rtk init -g`)

#### [context-mode](https://github.com/mksglu/context-mode)

MCP plugin that virtualizes Claude Code's context window. Routes large outputs through a sandboxed FTS5 knowledge base so raw tool output never floods the conversation.

```shell
# Inside Claude Code:
/plugin marketplace add mksglu/context-mode
/plugin install context-mode@context-mode

# Verify
/context-mode:ctx-doctor
```

Slash commands: `/context-mode:ctx-stats`, `/context-mode:ctx-doctor`, `/context-mode:ctx-upgrade`

#### [claude-hud](https://github.com/jarrodwatts/claude-hud)

Status line plugin showing context usage, active tools, running agents, and task progress.

```shell
# Inside Claude Code:
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
# Restart Claude Code
```

#### [code-review-graph](https://github.com/tirth8205/code-review-graph)

Local knowledge graph for Claude Code. Builds a persistent map of the codebase so Claude reads only what matters — 6.8x fewer tokens on reviews.

```shell
# Inside Claude Code:
/plugin marketplace add tirth8205/code-review-graph
/plugin install code-review-graph@code-review-graph

# Then in your project:
# "Build the code review graph for this project"
```

Requires Python 3.10+ and [uv](https://docs.astral.sh/uv/).

#### [fff (Fast File Finder)](https://github.com/dmtrKovalenko/fff.nvim)

Frecency-ranked file search MCP server. Also a Neovim plugin. Boosts git-dirty files and recently/frequently accessed files.

```shell
curl -L https://dmtrkovalenko.dev/install-fff-mcp.sh | bash
```

Add to `CLAUDE.md`:
```
For any file search or grep in the current git indexed directory use fff tools
```

#### [Plannotator](https://plannotator.ai)

Plan and code review UI for AI coding agents. Annotate agent plans before they execute, review diffs before committing.

```shell
curl -fsSL https://plannotator.ai/install.sh | bash
```

Slash commands: `/plannotator-review`, `/plannotator-annotate`, `/plannotator:plannotator-last`

#### [Impeccable](https://impeccable.style)

Design fluency skills for AI harnesses. Enhanced frontend-design skill + 20 design commands (/polish, /audit, /typeset, /overdrive, etc.).

```shell
npx skills add pbakaus/impeccable

# Or inside Claude Code:
/plugin marketplace add pbakaus/impeccable

# One-time project setup:
/teach-impeccable
```

Update: `npx skills update`

---

### OpenClaw Skills

Custom skills installed at `~/.agents/skills/`.

| Skill | Source | Description |
|-------|--------|-------------|
| `dalp-dev` | `~/.agents/skills/dalp-dev.skill` | DALP project development conventions |
| `dev-status` | `~/.agents/skills/dev-status.skill` | Development status reporting |
---

### Editor

#### [Neovim](https://neovim.io)

AstroNvim-based config with fff.nvim integration.

```shell
brew install neovim
```

Config: `~/.config/nvim/`

#### [Zed](https://zed.dev)

Secondary editor.

Config: `~/.config/zed/settings.json`, `~/.config/zed/prompts/`, `~/.config/zed/themes/`

---

### Other Tools

| Tool | Config |
|------|--------|
| [lazygit](https://github.com/jesseduffield/lazygit) | `~/.config/lazygit/config.yml` |
| [btop](https://github.com/aristocratos/btop) | `~/.config/btop/btop.conf` |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org) | `~/.config/karabiner/karabiner.json` |
| [bat](https://github.com/sharkdp/bat) | `~/.config/bat/` |

---

### Package Management

All Homebrew formulae and casks tracked in `~/.Brewfile`:

```shell
# Restore on new machine
brew bundle --global

# Update after installing/removing packages
brew bundle dump --global --force
```
