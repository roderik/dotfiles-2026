function __wt_tab_setup --description "Open a new workspace tab scoped to a directory — auto-detects zellij/cmux/bare"
    set -l cli "claude --dangerously-skip-permissions"
    set -l prompt ""
    set -l tab_name ""
    set -l workdir (pwd)

    argparse 'x' 'cli=' 'prompt=' 'name=' 'dir=' -- $argv 2>/dev/null

    set -q _flag_cli; and set cli $_flag_cli
    set -q _flag_x; and set cli "codex --full-auto"
    set -q _flag_prompt; and set prompt $_flag_prompt
    set -q _flag_name; and set tab_name $_flag_name
    set -q _flag_dir; and set workdir $_flag_dir

    # Build the command to type into the main pane
    set -l launch_cmd
    if test -n "$prompt"
        set launch_cmd "$cli '$prompt'"
    else
        set launch_cmd "$cli"
    end

    # ── Zellij ───────────────────────────────────────────────────────────
    if test -n "$ZELLIJ"
        __wt_tab_setup_zellij "$workdir" "$tab_name" "$launch_cmd"

        # For codex with a prompt, send the command after startup
        if set -q _flag_x; and test -n "$prompt"
            sleep 3
            zellij action write-chars "$prompt"
            zellij action write 10
        end
        return 0
    end

    # ── Cmux ─────────────────────────────────────────────────────────────
    if set -q CMUX_WORKSPACE_ID; and command -q cmux
        __wt_tab_setup_cmux "$workdir" "$tab_name" "$launch_cmd" "$cli" "$prompt"

        # For codex with a prompt, send the command after startup
        if set -q _flag_x; and test -n "$prompt"
            set -l ws_id "$CMUX_WORKSPACE_ID"
            set -l main_pane (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -oE 'pane:[0-9]+' | head -1)
            set -l main_surface (cmux list-pane-surfaces --workspace "$ws_id" --pane "$main_pane" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
            if test -n "$main_surface"
                sleep 3
                cmux send --workspace "$ws_id" --surface "$main_surface" "$prompt\n" 2>/dev/null
            end
        end
        return 0
    end

    # ── Bare terminal ────────────────────────────────────────────────────
    cd "$workdir"
    echo "Launching: $launch_cmd"
    eval $launch_cmd
end

# ── Zellij backend ───────────────────────────────────────────────────────
function __wt_tab_setup_zellij
    set -l workdir $argv[1]
    set -l tab_name $argv[2]
    set -l launch_cmd $argv[3]

    zellij action new-tab --layout wt --cwd "$workdir" 2>/dev/null
    sleep 0.5

    if test -n "$tab_name"
        zellij action rename-tab "$tab_name" 2>/dev/null
    end

    # Main pane is focused — launch CLI
    zellij action write-chars "$launch_cmd"
    zellij action write 10
end

# ── Cmux backend ─────────────────────────────────────────────────────────
function __wt_tab_setup_cmux
    set -l workdir $argv[1]
    set -l tab_name $argv[2]
    set -l launch_cmd $argv[3]
    set -l cli $argv[4]
    set -l prompt $argv[5]

    # Resolve workspace ID
    set -l ws_id
    if test -n "$CMUX_WORKSPACE_ID"
        set ws_id "$CMUX_WORKSPACE_ID"
    else
        set ws_id (cmux identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['workspace_ref'])" 2>/dev/null)
    end
    if test -z "$ws_id"
        echo "cmux: could not resolve workspace"
        return 1
    end

    # Rename workspace
    if test -n "$tab_name"
        cmux workspace-action --action rename --title "$tab_name" 2>/dev/null
    end

    # Get main pane/surface
    set -l main_pane (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -oE 'pane:[0-9]+' | head -1)
    if test -z "$main_pane"
        echo "cmux: could not detect panes"
        return 1
    end

    set -l main_surface (cmux list-pane-surfaces --workspace "$ws_id" --pane "$main_pane" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
    if test -z "$main_surface"
        echo "cmux: could not detect main surface"
        return 1
    end

    # Idempotency — only create layout if single pane
    set -l pane_count (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -cE 'pane:[0-9]+')
    if test "$pane_count" -le 1
        # Right split → lazygit
        set -l lg_surface (cmux new-split right --workspace "$ws_id" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
        if test -n "$lg_surface"
            cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -R --amount 200 2>/dev/null
            cmux send --workspace "$ws_id" --surface "$lg_surface" "cd '$workdir' && lazygit\n" 2>/dev/null
            cmux rename-tab --workspace "$ws_id" --surface "$lg_surface" "Git" 2>/dev/null
        end

        # Bottom split under main → terminal
        set -l term_surface (cmux new-split down --workspace "$ws_id" --surface "$main_surface" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
        if test -n "$term_surface"
            cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -D --amount 500 2>/dev/null
            cmux send --workspace "$ws_id" --surface "$term_surface" "cd '$workdir'\n" 2>/dev/null
            cmux rename-tab --workspace "$ws_id" --surface "$term_surface" "Terminal" 2>/dev/null
        end
    end

    # Launch CLI in main pane
    cmux focus-pane --pane "$main_pane" --workspace "$ws_id" 2>/dev/null
    if test -n "$prompt"
        cmux send --workspace "$ws_id" --surface "$main_surface" "$cli '$prompt'\n" 2>/dev/null
    else
        cmux send --workspace "$ws_id" --surface "$main_surface" "$cli\n" 2>/dev/null
    end
end
