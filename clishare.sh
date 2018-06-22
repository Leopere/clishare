#!/bin/bash
## This script has zero fanciness whatsoever so YMMV

# Doing a bit of brutish nonsense here.
printf 'removing any screens which might conflict before we run this.'

function clishare_cleanup () {
  tmux kill-session -t clishare
  tmux kill-session -t gotty
  ## We could put in a check here but its better to run latest anyways.
  rm /tmp/gott*
}

clishare_cleanup

function die () {
    local message=$1
    [ -z "$message" ] && message="Died"
    echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
    exit 1
}

## Guarantee we're using bash in case theres something weird happening.
if ! [[ $SHELL == "/bin/bash" ]]; then
  printf "Unfortunately this shell only supports bash."
  die
fi

## Detect Operating System if Linux or Mac
unameOut="$(uname -s)"
case "${unameOut}" in
  Linux* )
    SYSTEM_OS=Linux
    ## Detect Linux CPU architecture
    MACHINE_TYPE=$(getconf LONG_BIT)
    case $MACHINE_TYPE in
      64 )
      printf "detected 64 bit cpu, getting 64 bit gotty binary"
      curl https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz > /tmp/gotty.tar.gz
      ;;
      32 )
      printf "detected 32 bit cpu, getting 32 bit gotty binary"
      curl https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_386.tar.gz > /tmp/gotty.tar.gz
      ;;
    esac
  ;;
  Darwin* )
    SYSTEM_OS=Mac
    ## Detect Mac CPU architecture
    MACHINE_TYPE=$(getconf LONG_BIT)
    case $MACHINE_TYPE in
      64 )
      printf "detected 64 bit cpu, getting 64 bit gotty binary"
      curl https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_darwin_amd64.tar.gz > /tmp/gotty.tar.gz
      ;;
      32 )
      printf "detected 32 bit cpu, getting 32 bit gotty binary"
      curl https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_darwin_amd64.tar.gz > /tmp/gotty.tar.gz
      ;;
    esac
  ;;
  CYGWIN* )
    SYSTEM_OS=Cygwin
    printf "Cygwin is not supported sorry windows users."
    die
  ;;
  MINGW* )
    SYSTEM_OS=MinGw
    printf "MinGw is not supported sorry."
    die
  ;;
  * )
    SYSTEM_OS="UNKNOWN:${unameOut}"
    printf "Unfortunately oprating system $SYSTEM_OS is not recognized."
    printf "This script is airing on the side of safety and will not run."
    die
  ;;
esac

if ! [[ -x "$(command -v tmux)" ]]; then
  curl -s https://raw.githubusercontent.com/chamunks/clishare/master/tmux-add.sh > /tmp/tmux-add.sh
  chmod +x /tmp/tmux-add.sh
  /tmp/tmux-add.sh install
fi

## Final prep pre execution.
curl https://raw.githubusercontent.com/chamunks/clishare/master/gotty-run.sh > /tmp/gotty-run.sh
tar -xf /tmp/gotty.tar.gz -C /tmp/
chmod +x /tmp/gotty-run.sh
chmod +x /tmp/gotty
cd /tmp/

## Reading the user into whats happening.
printf "This will run a process where you can share(view only) your terminal with a friend via their web browser."
printf "You will need to run the command: screen -xr clishare"
printf "From a separate terminal/putty window."

tmux new -A -D -d -s gotty /tmp/gotty-run.sh

printf 'press [ENTER] to terminate clishare...'
read _
printf 'cleaning up old screens.'
## This might clean up after itself if we're lucky.  I'm not being picky or precise here.
clishare_cleanup

if [[ -f /tmp/tmux-add.sh ]]; then
  /tmp/tmux-add.sh uninstall
fi
