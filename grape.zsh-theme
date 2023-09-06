#!/usr/bin/env zsh
# grape - simple customizable prompt theme inspired by passion, af-magic
#
# af-magic: https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/af-magic.zsh-theme
# passion: https://github.com/ChesterYue/ohmyzsh-theme-passion

ZSH_THEME_GIT_RPROMPT_SYMBOL="";
ZSH_THEME_GIT_RPROMPT_SYMBOL_ERROR="";
ZSH_THEME_GIT_RPROMPT_LAST_CMD_TRUE_SYM="%{$fg_bold[green]%}${ZSH_THEME_GIT_RPROMPT_SYMBOL}";
ZSH_THEME_GIT_RPROMPT_LAST_CMD_FALSE_SYM="%{$fg_bold[red]%}${ZSH_THEME_GIT_RPROMPT_SYMBOL_ERROR}";
ZSH_THEME_GIT_RPROMPT_SEPARATOR=" %{$fg_no_bold[black]%}%{$reset_color%} ";

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[020]%} ";
ZSH_THEME_GIT_PROMPT_BRACH_COLOR="%{$FG[002]%}";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}";
ZSH_THEME_GIT_PROMPT_END_SUFFIX="%{$fg_no_bold[blue]%}%{$reset_color%}";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$FG[002]%}+%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}!%{$reset_color%}"

ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX="$FG[147]⇡"
ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX="$FG[147]⇣"
ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_FETCH_STATUS="0"
ZSH_THEME_GIT_FETCH_STATUS_INTERVAL="120"
ZSH_THEME_GIT_STATUS=""

ZSH_THEME_BATTERY_PREFIX=""
ZSH_THEME_BATTERY_SUFFIX=""
ZSH_THEME_BATTERY_CHARGING_COLOR="%{$fg_bold[green]%}"
ZSH_THEME_BATTERY_CHARGING_SYM=" "
ZSH_THEME_BATTERY_LOW_COLOR="%{$FG[001]%}"
ZSH_THEME_BATTERY_MED_COLOR="%{$FG[003]%}"
ZSH_THEME_BATTERY_FULL_COLOR="%{$FG[002]%}"

ZSH_THEME_CLOCK_COLOR="%{$FG[006]%}"
ZSH_THEME_CLOCK_PREFIX=""
ZSH_THEME_CLOCK_SUFFIX=""

ZSH_THEME_ZSH_ASYNC_VERSION='v1.8.6';

# Install zsh-async if it’s not present
if [[ ! -a ~/.zsh-async ]]; then
  git clone -b ${ZSH_THEME_ZSH_ASYNC_VERSION} https://github.com/mafredri/zsh-async ~/.zsh-async
fi
source ~/.zsh-async/async.zsh
# Initialize zsh-async
async_init
async_start_worker update_git_status_worker -n -u


function strf_real_time() {
  local time_str;
  local format=${1:='%Y-%m-%d {%u} %H:%M:%S'}
  strftime -s time_str ${format} $EPOCHSECONDS
  # strftime -s time_str "%Y-%m-%d {%u} %H:%M:%S" $EPOCHSECONDS
  local time="${time_str}";
  # local time="${ZSH_THEME_CLOCK_PREFIX}${time_str}${ZSH_THEME_CLOCK_SUFFIX}";
  echo -e ${time}
}

# time
function real_time() {
  local color="${ZSH_THEME_CLOCK_COLOR}"; # color in PROMPT need format in %{XXX%} which is not same with echo
  local _time="$(strf_real_time '%H:%M:%S')"
  local color_reset="%{$reset_color%}";
  echo "${color}${_time}${color_reset}";
}

# directory
function directory() {
  local color="$FG[111]";
  # REF: https://stackoverflow.com/questions/25944006/bash-current-working-directory-with-replacing-path-to-home-folder
  local directory="${PWD/#$HOME/~}";
  local color_reset="%{$reset_color%}";
  echo "${color}$(basename ${directory})${color_reset}";
}

function __git_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ZSH_THEME_GIT_PROMPT_BRACH_COLOR}${ref#refs/heads/}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

function vscode_git_status() {
  [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return

  # Maps a git status prefix to an internal constant
  # This cannot use the prompt constants, as they may be empty
  local -A prefix_constant_map
  prefix_constant_map=(
  '\?\? '          'UNTRACKED'
  '[MTARC][ MTD] '  'STAGED'
  'D  '            'STAGED'
  ' [AMTD] '       'UNSTAGED'
  '[MTARC][MTD] '  'UNSTAGED'
  '[DAU][DAU] '    'UNMERGED'
  'ahead'          'AHEAD'
  'behind'         'BEHIND'
  'diverged'       'DIVERGED'
  'stashed'        'STASHED'
  )

  # Maps the internal constant to the prompt theme
  local -A constant_prompt_map
  constant_prompt_map=(
  'UNTRACKED'         "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  'ADDED'             "$ZSH_THEME_GIT_PROMPT_ADDED"
  'MODIFIED'          "$ZSH_THEME_GIT_PROMPT_MODIFIED"
  'RENAMED'           "$ZSH_THEME_GIT_PROMPT_RENAMED"
  'DELETED'           "$ZSH_THEME_GIT_PROMPT_DELETED"
  'UNMERGED'          "$ZSH_THEME_GIT_PROMPT_UNMERGED"
  'AHEAD'             "$(git_commits_ahead)"
  'BEHIND'            "$(git_commits_behind)"
  'DIVERGED'          "$ZSH_THEME_GIT_PROMPT_DIVERGED"
  'STASHED'           "$ZSH_THEME_GIT_PROMPT_STASHED"
  'STAGED'            "$ZSH_THEME_GIT_PROMPT_STAGED"
  'UNSTAGED'          "$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  )

  # The order that the prompt displays should be added to the prompt
  local status_constants
  status_constants=(
  UNTRACKED ADDED MODIFIED RENAMED DELETED
  STASHED UNMERGED AHEAD BEHIND DIVERGED STAGED UNSTAGED
  )

  local status_text
  status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)"

  # Don't continue on a catastrophic failure
  if [[ $? -eq 128 ]]; then
  return 1
  fi

  # A lookup table of each git status encountered
  local -A statuses_seen

  if __git_prompt_git rev-parse --verify refs/stash &>/dev/null; then
  statuses_seen[STASHED]=1
  fi

  local status_lines
  status_lines=("${(@f)${status_text}}")

  # If the tracking line exists, get and parse it
  if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]; then
  local branch_statuses
  branch_statuses=("${(@s/,/)match}")
  for branch_status in $branch_statuses; do
    if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]; then
    continue
    fi
    local last_parsed_status=$prefix_constant_map[$match[1]]
    statuses_seen[$last_parsed_status]=$match[2]
  done
  fi

  # For each status prefix, do a regex comparison
  for status_prefix in ${(k)prefix_constant_map}; do
  local status_constant="${prefix_constant_map[$status_prefix]}"
  local status_regex=$'(^|\n)'"$status_prefix"

  if [[ "$status_text" =~ $status_regex ]]; then
    statuses_seen[$status_constant]=1
  fi
  done

  # Display the seen statuses in the order specified
  local status_prompt
  for status_constant in $status_constants; do
  if (( ${+statuses_seen[$status_constant]} )); then
    local next_display=$constant_prompt_map[$status_constant]
    status_prompt="$next_display$status_prompt"
  fi
  done

  echo $status_prompt
}

function update_git_status() {
  if __git_prompt_git rev-parse --git-dir &>/dev/null; then
    GIT_STATUS=$(__git_branch);
    local git_status="$(vscode_git_status)"
    if [[ $git_status != "" ]]; then
      GIT_STATUS+=" ${git_status}";
    fi
    GIT_STATUS+=${ZSH_THEME_GIT_PROMPT_END_SUFFIX};
  else
    GIT_STATUS=""
  fi
}

function git_status() {
  update_git_status;
  if [ ! -z "${GIT_STATUS}" ]; then
    echo "${GIT_STATUS}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}";
  else
    echo "${GIT_STATUS}";
  fi
}

# command
function update_command_status() {
  local arrow="";
  local color_reset="%{$reset_color%}";
  local reset_font="%{$fg_no_bold[white]%}";
  COMMAND_RESULT=$1;
  export COMMAND_RESULT=$COMMAND_RESULT
  if $COMMAND_RESULT;
  then
    arrow="${ZSH_THEME_GIT_RPROMPT_LAST_CMD_TRUE_SYM}";
  else
    arrow="${ZSH_THEME_GIT_RPROMPT_LAST_CMD_FALSE_SYM}";
  fi
  COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}

function command_status() {
  echo "${COMMAND_STATUS}"
}

# settings
typeset +H return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
typeset +H my_gray="$FG[237]"
typeset +H my_orange="$FG[214]"
typeset +H my_purple="$FG[135]"

# separator dashes size
function afmagic_dashes {
  local ratio=1
  echo $((COLUMNS * ratio))
}

current_time_millis() {
  local time_millis;
  time_millis=$EPOCHREALTIME
  echo $time_millis;
}

# output command execute after
output_command_execute_after() {
  if [ "$COMMAND_TIME_BEIGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEIGIN" = "" ];
  then
    return 1;
  fi

  # cmd
  local cmd="${$(fc -l | tail -1)#*  }";
  local color_cmd="";
  if $1;
  then
    color_cmd="$fg_no_bold[green]";
  else
    color_cmd="$fg_bold[red]";
  fi
  local color_reset="$reset_color";
  cmd="${color_cmd}${cmd}${color_reset}"

  # time
  # you can use the real_time command to replace
  local color_time="${ZSH_THEME_CLOCK_COLOR}";
  _time=$(print -P "${color_time}$(strf_real_time)${color_reset}");

  # cost
  local time_end="$(current_time_millis)";
  local cost=$(bc -l <<<"${time_end}-${COMMAND_TIME_BEIGIN}");
  COMMAND_TIME_BEIGIN="-20200325"
  local length_cost=${#cost};
  if [ "$length_cost" = "11" ]; # 11 means the length of cost
  then
    cost="0${cost}"
  fi
  cost="cost ${cost}s"
  local color_cost="$fg_no_bold[yellow]";
  cost="${color_cost}${cost}${color_reset}";

  local echo_dark_gray="$fg_no_bold[black]"
  print -P "${_time}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}${cost}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}${cmd}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}${echo_dark_gray}$(pwd)${color_reset}";
  print -P "${echo_dark_gray}${(l.$(afmagic_dashes)..-.)}${color_reset}"
}

# command execute before
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
preexec() {
  COMMAND_TIME_BEIGIN="$(current_time_millis)";
}

async_update_git_status(){
  async_job update_git_status_worker update_git_status &
  echo -e "${ZSH_THEME_GIT_STATUS}"
}

# command execute after
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
grape_precmd() {
  # last_cmd
  local last_cmd_return_code=$?;
  local last_cmd_result=true;
  if [ "$last_cmd_return_code" = "0" ];
  then
    last_cmd_result=true;
  else
    last_cmd_result=false;
  fi

  # update_git_status
  async_job update_git_status_worker update_git_status;

  # update_command_status
  update_command_status $last_cmd_result;

  # output command execute after
  output_command_execute_after $last_cmd_result;

}

function __git_fetch_status(){
  __git_prompt_git rev-parse --is-inside-work-tree &>/dev/null || return 0
  __git_prompt_git fetch -q --all 2>/dev/null
}

function git_fetch_status() {
  __git_fetch_status &!
}

update_git_status_callback() {
  ZSH_THEME_GIT_STATUS="$(git_status)"
}

function grape_chpwd() {
  __git_prompt_git rev-parse --is-inside-work-tree &>/dev/null || ZSH_THEME_GIT_STATUS="" && return 0
  __git_prompt_git update-index --refresh --assume-unchanged -q &>/dev/null
  update_git_status_callback
}

battery() {
  local battery_pcta=$(battery_pct_prompt);
  if [ "$battery_pcta" = "∞" ];then
    echo "${ZSH_THEME_BATTERY_CHARGING_COLOR}${ZSH_THEME_BATTERY_CHARGING_SYM}%{$reset_color%}";
    # echo "";
  else
    if [[ $(battery_pct) -gt 50 ]]; then
      color="${ZSH_THEME_BATTERY_FULL_COLOR}"
    elif [[ $(battery_pct) -gt 20 ]]; then
      color="${ZSH_THEME_BATTERY_MED_COLOR}"
    else
      color="${ZSH_THEME_BATTERY_LOW_COLOR}"
    fi
    echo "${color}${ZSH_THEME_BATTERY_PREFIX}$(battery_pct)%%${ZSH_THEME_BATTERY_SUFFIX}%{$reset_color%}"
  fi
}

# real time clock for zsh.
# https://stackoverflow.com/questions/2187829/constantly-updated-clock-in-zsh-prompt
schedprompt() {
  emulate -L zsh
  zmodload -i zsh/sched

  if [[ -z "ASYNC_PTYS" ]] || [[ "$ASYNC_PTYS" != *update_git_status_worker* ]]; then
    async_start_worker update_git_status_worker -n -u
  if

  if [[ -z $ASYNC_CALLBACKS ]]; then
    async_start_worker update_git_status_worker -n -u
    async_register_callback update_git_status_worker update_git_status_callback
  else
    typeset -gA ASYNC_CALLBACKS
    local callback=$ASYNC_CALLBACKS[update_git_status_worker]
    if [[ -z $callback ]]; then
      async_register_callback update_git_status_worker update_git_status_callback
    fi
  fi

  integer i=${"${(@)zsh_scheduled_events#*:*:}"[(I)git_fetch_status]}
  # git_fetch_all periodically.
  (( i )) || sched +${ZSH_THEME_GIT_FETCH_STATUS_INTERVAL} git_fetch_status

  # Remove existing event, so that multiple calls to
  # "schedprompt" work OK.  (You could put one in precmd to push
  # the timer 30 seconds into the future, for example.)
  integer i=${"${(@)zsh_scheduled_events#*:*:}"[(I)schedprompt]}
  (( i )) && sched -$i

  # Test that zle is running before calling the widget (recommended
  # to avoid error messages).
  # Otherwise it updates on entry to zle, so there's no loss.
  # `zle .reset-prompt` worked in centos 7.
  if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
    zle && zle .reset-prompt;
  fi

  # This ensures we're not too far off the start of the minute
  # update zle for every second.
  sched +1 schedprompt
}

update_command_status true;
zmodload -i zsh/datetime

# Register callback function for the workers completed jobs
async_register_callback update_git_status_worker update_git_status_callback

setopt prompt_subst

PROMPT='$(directory) $(command_status) ';
RPROMPT='$(async_update_git_status)$(real_time)${ZSH_THEME_GIT_RPROMPT_SEPARATOR}%{$FG[242]%}%n@%m${color_reset}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}$(battery)${color_reset}';

autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd grape_precmd
add-zsh-hook -Uz chpwd grape_chpwd
schedprompt