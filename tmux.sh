#!/usr/bin/env bash
#   
# File: tmux.sh
# Author: Timothy Lee
# Description: wrapper to create tmux session.
# Version: 0.1
# Date: 2012-12-28
# Todo: None
#   

CONFIG_BASE=./config
CONFIG_LOCAL=$CONFIG_BASE/local
CONFIG_SERVER=$CONFIG_BASE/server

function check_config() {
    case $1 in
        local)
            CONFIG="$CONFIG_LOCAL/$2.tmux"
            ;;
        server)
            CONFIG="$CONFIG_SERVER/$2.tmux"
            ;;
            *)
            CONFIG=""
            ;;
    esac
    if [[ -f $CONFIG ]]; then
        bash -n $CONFIG 2>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "Error, syntax error!"
            exit 1
        fi
        . $CONFIG
        if [[ -z $SESSION ]] || [[ -z $WINDOWS ]]; then
            echo "Error, can't not parse config!"
            exit 1
        fi
    else
        echo "Error, no such config!"
        exit 1
    fi
}

function init_session() {
    SESSION=$SESSION'_'$(date +"%s")_"$RANDOM"
    tmux new-session -d -s "$SESSION"
}

function strip_cmd() {
    echo $@ | sed -e "s/^['\"]//g" -e "s/['\"]$//g"
}

function parse_windows() {
    if [[ ! -z $(echo $WINDOWS | grep -v '-') ]]; then
        for window in $WINDOWS; do
            echo $window
        done
    else
        while read line; do
            line=$(echo $line | grep -vE "^(SESSION|COLOR|WINDOWS)")
            if [[ ! -z $line ]]; then
                echo $line
            fi
        done < $CONFIG
    fi
}

function init_windows() {
    case $1 in
        local)
            cmd_prefix=""
            ;;
        server)
            cmd_prefix="ssh"
            ;;
    esac
    i=1
    parse_windows | while read window; do
        cmd=$(strip_cmd "$cmd_prefix $(echo $window | cut -d'/' -f'1')")
        name=$(echo $window | cut -d'/' -f'2')
        if [[ ! -z $cmd ]] && [[ ! -z $name ]]; then
            tmux new-window -t "$SESSION":$i -n $name "$cmd"
        fi
        i=$(($i+1))
    done
    tmux kill-window -t "$SESSION":0
}

function colour(){
    #for i in {0..255} ; do
    #    printf "\x1b[38;5;${i}mcolour${i}\n"
    #done
    case $1 in
        red)
            echo colour{196..201}
            ;;
        green)
            echo colour{118..123}
            ;;
        blue)
            echo colour{27..23}
            ;;
        cyan)
            echo colour{39..35}
            ;;
        yellow)
            echo colour{226..230}
            ;;
        purple)
            echo colour{93..89}
            ;;
        gary)
            echo colour{239..249}
            ;;
        *)
            echo colour{1..15}
            ;;
    esac
}

function color_on(){
    i=1
    colors=($(colour $COLOR))
    for window in $WINDOWS; do
        color=${colors["$(($i-1))"]}
        r=1
        while [[ -z $color ]]; do
            color=${colors["$(($i - 1 - ${#colors[@]} * $r))"]}
            r=$(($r+1))
        done
        tmux set-window-option -t "$SESSION":"$i" window-status-fg $color
        i=$(($i+1))
    done
}

function enter() {
    tmux select-window -t "$SESSION":1
    tmux -2 attach-session -t "$SESSION"
}

case $1 in
    local)
        check_config local $2
        init_session
        init_windows local
        color_on
        enter
        ;;
    server)
        check_config server $2
        init_session
        init_windows server
        color_on
        enter
        ;;
        *)
        echo "Useage: $0 {local|server}"
        ;;
esac

