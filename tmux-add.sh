#!/bin/bash
case $1 in
  install )
  source <(curl -s https://gist.githubusercontent.com/ryin/3106801/raw/c3382b8bda16706f530614329b0af7d0e90075aa/tmux_local_install.sh)
  echo $PATH | grep -q '$HOME/local/bin'; [ $? -ne 0 ] && export PATH=$PATH:'$HOME/local/bin'
    ;;
  uninstall )
    tmux kill-server
    rm -Rf $HOME/local
    ;;
esac
