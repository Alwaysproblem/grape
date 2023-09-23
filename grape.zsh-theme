#!/usr/bin/env zsh
# grape - simple customizable prompt theme inspired by passion, af-magic
#
# af-magic: https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/af-magic.zsh-theme
# passion: https://github.com/ChesterYue/ohmyzsh-theme-passion
# gitstatus: https://github.com/romkatv/gitstatus

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

ZSH_THEME_GITSTATUS_VERSION='v1.5.3';

# Install zsh-async if it’s not present
if [[ ! -a ~/gitstatus ]]; then
  git clone -b ${ZSH_THEME_GITSTATUS_VERSION} --depth=1 https://github.com/romkatv/gitstatus.git ~/gitstatus
fi
source ~/gitstatus/gitstatus.plugin.zsh

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

function update_git_status() {
  emulate -L zsh
  typeset -g GIT_STATUS=''

  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local p
  local where  # branch name, tag or commit

  p+="${ZSH_THEME_GIT_PROMPT_PREFIX}${ZSH_THEME_GIT_PROMPT_BRACH_COLOR}"
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='%f#'
    where=$VCS_STATUS_TAG
  else
    p+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  p+="${where//\%/%%}${ZSH_THEME_GIT_PROMPT_SUFFIX}"             # escape %

  (( VCS_STATUS_COMMITS_BEHIND \
     || VCS_STATUS_COMMITS_AHEAD \
     || VCS_STATUS_COMMITS_AHEAD \
     || VCS_STATUS_NUM_STAGED \
     || VCS_STATUS_NUM_UNSTAGED \
     || VCS_STATUS_NUM_UNTRACKED \
     || VCS_STATUS_NUM_CONFLICTED )) && p+=" "

  (( VCS_STATUS_COMMITS_BEHIND )) && p+="${ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX}${VCS_STATUS_COMMITS_BEHIND}${ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX}"
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+="${ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX}${VCS_STATUS_COMMITS_AHEAD}${ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX}"
  (( VCS_STATUS_NUM_STAGED     )) && p+="${ZSH_THEME_GIT_PROMPT_STAGED}"
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+="${ZSH_THEME_GIT_PROMPT_UNSTAGED}"
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+="${ZSH_THEME_GIT_PROMPT_UNTRACKED}"
  (( VCS_STATUS_NUM_CONFLICTED )) && p+="${ZSH_THEME_GIT_PROMPT_UNMERGED}"

  GIT_STATUS="${p}"
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
  update_git_status;

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

gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

setopt prompt_subst

PROMPT='$(directory) $(command_status) ';
RPROMPT='$(git_status)$(real_time)${ZSH_THEME_GIT_RPROMPT_SEPARATOR}%{$FG[242]%}%n@%m${color_reset}${ZSH_THEME_GIT_RPROMPT_SEPARATOR}$(battery)${color_reset}';

autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd grape_precmd
add-zsh-hook -Uz chpwd grape_chpwd
schedprompt
