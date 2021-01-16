#! /usr/bin/env bash
# shellcheck disable=SC2029
# shellcheck disable=SC2039

GREEN="\e[0;32m"
RESET="\e[m"
ORANGE="\e[0;33m"
BLUE="\e[0;94m"

echo_cmd () {
    echo -e "${BLUE}→ ${1} ${RESET}"
}

echo_and_ssh () {
    (
        echo_cmd "${2}"
        ssh "${1}" "${2}"
    )
}

(
    cd configuration/hosts || exit
    for host in * ; do
        if [ "$host" = "$(hostname)" ]; then
            sleep 0.1
        else
            (
                echo -e ""
                echo -e "${GREEN}#=================================================================="
                echo -e "# $host ${RESET}"
                echo -e "${ORANGE}#-------- git pull -------${RESET}"

                echo_and_ssh "$host" "sudo git -C /etc/nixfiles/ config pull.ff only"
                echo_and_ssh "$host" "sudo git -C /etc/nixfiles/ pull"

                echo -e "${ORANGE}#-------- nixos-rebuild switch -------${RESET}"

                echo_and_ssh "$host" "sudo /etc/nixfiles/nixos-rebuild.sh switch"
            )
        fi
    done
)
