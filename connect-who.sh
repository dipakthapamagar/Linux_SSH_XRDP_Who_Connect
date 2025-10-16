#!/bin/bash

RED=$(tput setaf 1; tput bold) #"\033[1;31m"
GREEN=$(tput setaf 2; tput bold) #"\033[1;32m"
YELLOW=$(tput setaf 3; tput bold)
ENDCOLOR=$(tput sgr0) #"\033[0m"

# Format string for printf
_printf="%-10s %-10s %-12s %-1s\n"

printf "\n${YELLOW}NOTE${ENDCOLOR}: Using ${GREEN}sudo${ENDCOLOR} gives accurate results in case of xrdp connection.\n"

# Print header
printf "\n${YELLOW}${_printf}${ENDCOLOR}" PID USERNAME CONNECTION STATUS

# Process active xrdp (Xorg) sessions
ps h -C Xorg -o user:20,pid,lstart,cmd | grep xrdp | while read username pid xorg_cmd; do
    ss -ep 2>/dev/null | grep '/xrdp_display' | grep -q pid\=${pid}, && status="${GREEN}active${ENDCOLOR}" || status="${RED}disconnected${ENDCOLOR}"
    printf "${_printf}" ${pid} "${username}" "xrdp" "${status}"
done

# Process active ssh sessions from 'w' command
w -h --pids | grep 'sshd' | awk '{split($7, pids, "/"); print $1, $2, pids[1]}' | while read user ip pid; do
    status="${GREEN}active${ENDCOLOR}"
    printf "${_printf}" "${pid}" ${user} "ssh" "${status} from ${GREEN}${ip}${ENDCOLOR}"
done

if output=$(ss -ep 2>/dev/null | grep ms-wbt-server | awk '{print $6}' | awk -F '[:\\]]' '{print $4}'); then
        if [ -n "${output}" ]; then
                printf "\n${YELLOW}RDP connection from:${ENDCOLOR}\n"
                printf "${GREEN}${output}${ENDCOLOR}"
        fi
fi
