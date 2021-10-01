# name: Agnoster Plus
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for FISH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).

## Set this options in your config.fish (if you want to :])
# set -g theme_display_user no
# set -g theme_hide_hostname yes
# set -g default_user your_normal_user
# set -g theme_svn_prompt_enabled yes

# Global vars
set -g current_bg NONE
set segment_separator \uE0B0
set right_segment_separator \uE0B0
set left_segment_separator \uE0B2
set left_arrow_glyph \uE0B3

# Theme
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g default_user your_normal_user

# ===========================
# Color setting

# You can set these variables in config.fish like:
# set -g color_dir_bg red
# If not set, default color from agnoster will be used.
# ===========================
set -q color_virtual_env_bg; or set color_virtual_env_bg white
set -q color_virtual_env_str; or set color_virtual_env_str black
set -q color_user_bg; or set color_user_bg black
set -q color_user_str; or set color_user_str yellow
set -q color_dir_bg; or set color_dir_bg blue
set -q color_dir_str; or set color_dir_str black
set -q color_hg_changed_bg; or set color_hg_changed_bg yellow
set -q color_hg_changed_str; or set color_hg_changed_str black
set -q color_hg_bg; or set color_hg_bg green
set -q color_hg_str; or set color_hg_str black
set -q color_git_dirty_bg; or set color_git_dirty_bg yellow
set -q color_git_dirty_str; or set color_git_dirty_str black
set -q color_git_bg; or set color_git_bg green
set -q color_git_str; or set color_git_str black
set -q color_svn_bg; or set color_svn_bg green
set -q color_svn_str; or set color_svn_str black
set -q color_status_nonzero_bg; or set color_status_nonzero_bg black
set -q color_status_nonzero_str; or set color_status_nonzero_str red
set -q color_status_superuser_bg; or set color_status_superuser_bg black
set -q color_status_superuser_str; or set color_status_superuser_str yellow
set -q color_status_jobs_bg; or set color_status_jobs_bg black
set -q color_status_jobs_str; or set color_status_jobs_str cyan
set -q color_status_private_bg; or set color_status_private_bg black
set -q color_status_private_str; or set color_status_private_str purple
set -q color_tree_segment_separator; or set color_tree_segment_separator 666666
set -q color_vi_mode_indicator; or set color_vi_mode_indicator black
set -q color_vi_mode_normal; or set color_vi_mode_normal green
set -q color_vi_mode_insert; or set color_vi_mode_insert blue
set -q color_vi_mode_visual; or set color_vi_mode_visual red


# ===========================
# Cursor setting

# You can set these variables in config.fish like:
# set -g cursor_vi_mode_insert bar_blinking
# ===========================
set -q cursor_vi_mode_normal; or set cursor_vi_mode_normal box_steady
set -q cursor_vi_mode_insert; or set cursor_vi_mode_insert bar_steady
set -q cursor_vi_mode_visual; or set cursor_vi_mode_visual box_steady

# ===========================
# Git settings
# set -g color_dir_bg red

set -q fish_git_prompt_untracked_files; or set fish_git_prompt_untracked_files normal

# ===========================
# Helper methods
# ===========================

set -g __fish_git_prompt_showdirtystate 'yes'
set -g __fish_git_prompt_char_dirtystate '±'
set -g __fish_git_prompt_char_cleanstate ''

function parse_git_dirty
  if [ $__fish_git_prompt_showdirtystate = "yes" ]
    set -l submodule_syntax
    set submodule_syntax "--ignore-submodules=dirty"
    set untracked_syntax "--untracked-files=$fish_git_prompt_untracked_files"
    set git_dirty (command git status --porcelain $submodule_syntax $untracked_syntax 2> /dev/null)
    if [ -n "$git_dirty" ]
        echo -n "$__fish_git_prompt_char_dirtystate"
    else
        echo -n "$__fish_git_prompt_char_cleanstate"
    end
  end
end

function prompt_segment -d "Function to draw a segment"
    set -l bg
    set -l fg

    if [ -n "$argv[1]" ]
        set bg $argv[1]
    else
        set bg normal
    end

    if [ -n "$argv[2]" ]
        set fg $argv[2]
    else
        set fg normal
    end

    if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
        set_color -b $bg
        set_color $current_bg
        echo -n "$segment_separator "
        set_color -b $bg
        set_color $fg
    else
        set_color -b $bg
        set_color $fg
        echo -n " "
    end

    set current_bg $argv[1]

    if [ -n "$argv[3]" ]
        echo -n -s $argv[3] " "
    end
end

function prompt_left_arrow_segment -d "Function to draw a left arrow segment"
    set_color $argv[1]
    printf "%s" "$left_segment_separator"
end

function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    set -l right_segment_separator \uE0B2
    set_color black
    echo -n -e "$right_segment_separator"
    set_color -b black white

    if [ $RETVAL -ne 0 ]
        set_color -b $color_status_nonzero_bg $color_status_nonzero_str
        echo -n -e " ✘ "
    else
        set_color -b black green
        echo -n -e " ✔ "
    end

    if [ "$fish_private_mode" ]
        set_color -b $color_status_private_bg $color_status_private_str
        echo -n -e "🔒"
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)

    if [ $uid -eq 0 ]
        set_color -b $color_status_superuser_bg $color_status_superuser_str
        echo -n -e "⚡"
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
        set_color -b $color_status_jobs_bg $color_color_status_jobs_str
        echo -n -e "⚙"
    end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
    set -g HOSTNAME_PROMPT ""
    if [ "$theme_hide_hostname" = "no" -o \( "$theme_hide_hostname" != "yes" -a -n "$SSH_CLIENT" \) ]
      set -g HOSTNAME_PROMPT (uname -n)
    end
  end

function prompt_user -d "Display current user if different from $default_user"
    if [ "$theme_display_user" = "yes" ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            set USER (whoami)
            get_hostname

            if [ $HOSTNAME_PROMPT ]
                set USER_PROMPT $USER@$HOSTNAME_PROMPT
            else
                set USER_PROMPT $USER
            end

            prompt_segment $color_user_bg $color_user_str $USER_PROMPT
        end
    else
        get_hostname
        if [ $HOSTNAME_PROMPT ]
            prompt_segment $color_user_bg $color_user_str $HOSTNAME_PROMPT
        end
    end
end

function prompt_dir -d "Display the current directory"
    prompt_segment $color_dir_bg $color_dir_str (prompt_pwd)
end

function prompt_git -d "Display the current git state"
    set -l ref
    set -l dirty

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set dirty (parse_git_dirty)
        set ref (command git symbolic-ref HEAD 2> /dev/null)
        if [ $status -gt 0 ]
            set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
            set ref "➦ $branch "
        end

        set branch_symbol \uE0A0
        set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")

        if [ "$dirty" != "" ]
            prompt_segment $color_git_dirty_bg $color_git_dirty_str "$branch $dirty"
        else
            prompt_segment $color_git_bg $color_git_str "$branch $dirty"
        end
    end
end

function prompt_finish -d "Close open segments"
    if [ -n $current_bg ]
        set_color normal
        set_color $current_bg
        echo -n "$segment_separator "
        set_color normal
    end

    set -g current_bg NONE
end

function concat_segments --argument-names previous next --description 'Concact two segments'
    printf "%s%s" "$previous" "$next"
end

function create_padding --argument-names amount --description 'Print N amount of spaces'
    printf "%-"$amount"s%s"
end

function remove_color --description 'Remove color escape sequences from string'
    printf $argv | perl -pe 's/\x1b.*?[mGKH]//g'
end

function __cmd_duration -S -d 'Show command duration'
    [ "$theme_display_cmd_duration" = "no" ]; and return
    [ "$CMD_DURATION" -lt 100 ]; and return

    if [ "$CMD_DURATION" -lt 5000 ]
        # less than 5s -> white
        set_color white
        echo -ns $CMD_DURATION 'ms'
    else if [ "$CMD_DURATION" -lt 60000 ]
        # between 5s and 1minutes -> orange
        set_color e69d6a
        printf "%s%s" (math --scale=1 $CMD_DURATION/1000 | sed 's/\\.0$//') 's'
    else if [ "$CMD_DURATION" -lt 3600000 ]
        set_color $fish_color_error
        printf "%s%s" (math --scale=1 $CMD_DURATION/60000 | sed 's/\\.0$//') 'm'
    else
        set_color $fish_color_error
        printf "%s%s" (math --scale=2 $CMD_DURATION/3600000 | sed 's/\\.0$//') 'h'
    end

    set_color $fish_color_normal
    set_color $fish_color_autosuggestion

    [ "$theme_display_date" = "no" ]
        or echo -ns ' ' $left_arrow_glyph
end

function __timestamp -S -d 'Show the current timestamp'
    [ "$theme_display_date" = "no" ]; and return
    set -q theme_date_format
      or set -l theme_date_format "+%a %b %d %T %Z %Y "

    echo -e -n ' '
    date $theme_date_format
end

function fish_cursor_name_to_code -a cursor_name -d "Translate cursor name to a cursor code"
    # these values taken from
    # https://github.com/gnachman/iTerm2/blob/master/sources/VT100Terminal.m#L1646
    # Beginning with the statement "case VT100CSI_DECSCUSR:"
    if [ $cursor_name = "box_blinking" ]
        echo 1
    else if [ $cursor_name = "box_steady" ]
        echo 2
    else if [ $cursor_name = "underline_blinking" ]
        echo 3
    else if [ $cursor_name = "underline_steady" ]
        echo 4
    else if [ $cursor_name = "bar_blinking" ]
        echo 5
    else if [ $cursor_name = "bar_steady" ]
        echo 6
    else
        echo 2
    end
end

function prompt_vi_mode -d 'vi mode status indicator'
    set -l right_segment_separator \uE0B2
    switch $fish_bind_mode
        case default
            set -l mode (fish_cursor_name_to_code $cursor_vi_mode_normal)
            echo -n -e "\e[\x3$mode q"
            set_color $color_vi_mode_normal
            echo -n -e "$right_segment_separator"
            set_color -b $color_vi_mode_normal $color_vi_mode_indicator
            echo -n -e " N "
        case insert
            set -l mode (fish_cursor_name_to_code $cursor_vi_mode_insert)
            echo -n -e "\e[\x3$mode q"
            set_color $color_vi_mode_insert
            echo -n -e "$right_segment_separator"
            set_color -b $color_vi_mode_insert $color_vi_mode_indicator
            echo -n -e " I "
        case visual
            set -l mode (fish_cursor_name_to_code $cursor_vi_mode_visual)
            echo -n -e "\e[\x3$mode q"
            set_color $color_vi_mode_visual
            echo -n -e "$right_segment_separator"
            set_color -b $color_vi_mode_visual $color_vi_mode_indicator
            echo -n -e " V "
    end
end

function fish_prompt
    # set the exit command `status` var to `RETVAL`: it will be used in `prompt_status` function
    set -g RETVAL $status
    set -l left_prompt ''
    set -l padding ''
    set -l right_prompt ' '
    set -l bottom_prompt ' '
    set -l left_arrow_segment_color black

    # draw the `╭─` char at the beginning of the first line prompt
    set left_prompt (concat_segments $left_prompt (set_color $color_tree_segment_separator)"╭─"(set_color normal))

    # Check if the var display user@host is:
    # -> TRUE: use the black color for left arrow segment
    # -> FALSE: use the blue color
    if [ "$theme_hide_hostname" = "yes" ]
        set left_arrow_segment_color blue
    end
    # draw the left arrow at the beginning of the firstline prompt
    set left_prompt (concat_segments $left_prompt (prompt_left_arrow_segment $left_arrow_segment_color))

    # user@host
    set left_prompt (concat_segments $left_prompt (prompt_user))

    # pwd
    set left_prompt (concat_segments $left_prompt (prompt_dir))

    # git status
    type -q git; and set left_prompt (concat_segments $left_prompt (prompt_git))

    # prompt_finish
    set left_prompt (concat_segments $left_prompt (prompt_finish))

    # took
    set right_prompt (concat_segments $right_prompt (set_color $fish_color_autosuggestion)(__cmd_duration)(set_color normal))


    # date and time
    set right_prompt (concat_segments $right_prompt (set_color $fish_color_autosuggestion)(__timestamp)(set_color normal))

    # draw the exit command status
    set right_prompt (concat_segments $right_prompt (prompt_status))

    # vi mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        set right_prompt (concat_segments $right_prompt (prompt_vi_mode))
    end

    # remove the background color after vi mode or prompt_status(if vi mode is disabled)
    set right_prompt (concat_segments $right_prompt (set_color normal))

    # second line
    set bottom_prompt (set_color $color_tree_segment_separator)"╰─ "(set_color normal)

    # Calculate padding
    set paddding (create_padding \
        (math $COLUMNS - (remove_color $left_prompt$right_prompt | string length)))

    # Print first line of the fish prompt
    printf "%s%s%s" "$left_prompt" "$paddding" "$right_prompt"
    # Jump to next line
    printf \n
    # Print second line of the fish prompt
    printf $bottom_prompt
end