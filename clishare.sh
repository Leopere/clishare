#!/bin/bash
## This script has zero fanciness whatsoever so YMMV
# set -e

## Add fancy die function
function die () {
    local message=$1
    [ -z "$message" ] && message="Died"
    echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
    return
}

## Check for tmux dependency.
if ! [[ -x "$(command -v tmux)" ]]; then
  die "Tmux is not installed please install tmux first and then re run this script."
  # curl -s https://raw.githubusercontent.com/chamunks/clishare/master/tmux-add.sh > /tmp/tmux-add.sh
  # chmod +x /tmp/tmux-add.sh
  # /tmp/tmux-add.sh install
fi

# Doing a bit of brutish nonsense here.
function clishare_cleanup () {
  tmux kill-session -t clishare
  tmux kill-session -t gotty
  ## We could put in a check here but its better to run latest anyways.
  rm /tmp/gott*
}
printf 'removing any screens which might conflict before we run this.'
clishare_cleanup

## Guarantee we're using bash in case theres something weird happening.

if [[ ! -n "$BASH" ]]; then
  die "Unfortunately this shell only supports bash."
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
      curl -L -o /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz
      ;;
      32 )
      printf "detected 32 bit cpu, getting 32 bit gotty binary"
      curl -L -o /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_386.tar.gz
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
      curl -L -o /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_darwin_amd64.tar.gz
      ;;
      32 )
      printf "detected 32 bit cpu, getting 32 bit gotty binary"
      curl -L -o /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_darwin_amd64.tar.gz
      ;;
    esac
  ;;
  CYGWIN* )
    SYSTEM_OS=Cygwin
    die "Cygwin is not supported sorry windows users."
  ;;
  MINGW* )
    SYSTEM_OS=MinGw
    die "MinGw is not supported sorry."
  ;;
  * )
    SYSTEM_OS="UNKNOWN:${unameOut}"
    printf "Unfortunately oprating system $SYSTEM_OS is not recognized."
    die "This script is airing on the side of safety and will not run."
  ;;
esac

## Final prep pre execution.
curl https://raw.githubusercontent.com/chamunks/clishare/master/gotty-run.sh > /tmp/gotty-run.sh
tar -xf /tmp/gotty.tar.gz -C /tmp/
chmod +x /tmp/gotty-run.sh
chmod +x /tmp/gotty
cd /tmp/

## Reading the user into whats happening.
echo "This will run a process where you can share(view only) your terminal with a friend via their web browser."
echo "You will need to run the command: screen -xr clishare"
echo "From a separate terminal/putty window."

tmux new -A -D -d -s gotty /tmp/gotty-run.sh

echo "Your temporary read only commandline sharing should now be available at."
echo 'http://'$(curl v4.ifconfig.co)':8080 and the console can be attached by entering:'
echo 'tmux attach -t clishare'
echo 'Warning: You may need to refresh the url a few times before the clishare tmux window will exist.'
echo 'press [ENTER] to terminate clishare...'
read _
printf 'cleaning up old screens.'
## This might clean up after itself if we're lucky.  I'm not being picky or precise here.
clishare_cleanup

if [[ -f /tmp/tmux-add.sh ]]; then
  /tmp/tmux-add.sh uninstall
fi
