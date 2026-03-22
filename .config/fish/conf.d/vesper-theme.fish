# Vesper theme for fish shell
# Based on Rauno Freiberg's Vesper — peppermint & orange dark theme
#
# Palette:
#   bg:        #101010    fg:       #b7b7b7    bright:   #ffffff
#   dim:       #505050    orange:   #FFC799    mint:     #99FFE4
#   red:       #EF4444    blue:     #ADD7FF    magenta:  #DEBAFF
#   surface:   #1E1E1E    muted:    #7B7B7B

if status is-interactive
    # Core syntax
    set -U fish_color_normal B7B7B7
    set -U fish_color_command FFC799
    set -U fish_color_keyword FFC799
    set -U fish_color_param ADD7FF
    set -U fish_color_option ADD7FF
    set -U fish_color_quote 99FFE4
    set -U fish_color_error EF4444
    set -U fish_color_comment 505050
    set -U fish_color_end 7B7B7B
    set -U fish_color_operator DEBAFF
    set -U fish_color_escape DEBAFF
    set -U fish_color_redirection ADD7FF
    set -U fish_color_autosuggestion 505050
    set -U fish_color_valid_path --underline

    # Selection & search
    set -U fish_color_selection --background=1E1E1E
    set -U fish_color_search_match --background=1E1E1E --bold

    # Completion pager
    set -U fish_pager_color_progress 505050
    set -U fish_pager_color_prefix 99FFE4 --bold
    set -U fish_pager_color_completion B7B7B7
    set -U fish_pager_color_description 505050
    set -U fish_pager_color_selected_background --background=1E1E1E

    # UI chrome
    set -U fish_color_cwd FFC799
    set -U fish_color_cwd_root EF4444
    set -U fish_color_user 99FFE4
    set -U fish_color_host B7B7B7
    set -U fish_color_host_remote FFC799
    set -U fish_color_status EF4444
    set -U fish_color_cancel 7B7B7B
    set -U fish_color_history_current --bold

    # Tide prompt — Vesper palette
    # Use hex colors for powerline segments
    set -U tide_character_color 99FFE4
    set -U tide_character_color_failure EF4444

    # Left prompt: os | pwd | git
    set -U tide_os_bg_color 1E1E1E
    set -U tide_os_color 7B7B7B

    set -U tide_pwd_bg_color 232323
    set -U tide_pwd_color_anchors FFC799
    set -U tide_pwd_color_dirs B7B7B7
    set -U tide_pwd_color_truncated_dirs 505050

    set -U tide_git_bg_color 99FFE4
    set -U tide_git_bg_color_unstable FFC799
    set -U tide_git_bg_color_urgent EF4444
    set -U tide_git_color_branch 101010
    set -U tide_git_color_conflicted 101010
    set -U tide_git_color_dirty 101010
    set -U tide_git_color_operation 101010
    set -U tide_git_color_staged 101010
    set -U tide_git_color_stash 101010
    set -U tide_git_color_untracked 101010
    set -U tide_git_color_upstream 101010

    # Right prompt segments
    set -U tide_status_bg_color 1E1E1E
    set -U tide_status_bg_color_failure EF4444
    set -U tide_status_color 99FFE4
    set -U tide_status_color_failure 101010

    set -U tide_cmd_duration_bg_color 1E1E1E
    set -U tide_cmd_duration_color 7B7B7B

    set -U tide_jobs_bg_color 1E1E1E
    set -U tide_jobs_color FFC799

    set -U tide_node_bg_color 99FFE4
    set -U tide_node_color 101010

    set -U tide_bun_bg_color FFC799
    set -U tide_bun_color 101010

    set -U tide_python_bg_color ADD7FF
    set -U tide_python_color 101010

    set -U tide_java_bg_color FFC799
    set -U tide_java_color 101010

    set -U tide_ruby_bg_color EF4444
    set -U tide_ruby_color 101010

    set -U tide_rustc_bg_color FFC799
    set -U tide_rustc_color 101010

    set -U tide_go_bg_color ADD7FF
    set -U tide_go_color 101010

    set -U tide_docker_bg_color ADD7FF
    set -U tide_docker_color 101010

    set -U tide_kubectl_bg_color DEBAFF
    set -U tide_kubectl_color 101010

    set -U tide_aws_bg_color FFC799
    set -U tide_aws_color 101010

    set -U tide_context_bg_color 1E1E1E
    set -U tide_context_color_default FFC799
    set -U tide_context_color_root EF4444
    set -U tide_context_color_ssh ADD7FF

    # Frame & separators
    set -U tide_prompt_color_frame_and_connection 505050
    set -U tide_prompt_color_separator_same_color 505050
end
