#! /usr/bin/env bash
# shellcheck disable=SC2016
# shellcheck disable=SC2029
# shellcheck disable=SC2039

BLUE="\e[0;94m"
GREEN="\e[0;32m"
ORANGE="\e[0;33m"
RED="\e[0;31m"
RESET="\e[m"

ACTION="$1"

if [[ -z $ACTION ]]; then
    echo -e "${RED}>>> !!! ERROR !!! <<<${RESET}"
    echo 'A `nixos-rebuild` action is waited as $1 (ex: `dry-build`, `test`, `switch`)'
    exit 1
fi

echo_cmd () {
    echo -e "${BLUE}→ ${1} ${RESET}"
}

echo_and_ssh () {
    echo_cmd "${2}"
    ssh "${1}" "${2}"
}

cd configuration/hosts || exit
for host in * ; do
    if [ "$host" = "$(hostname)" ]; then
        sleep 0.1
    else
        echo -e ""
        echo -e "${GREEN}#=================================================================="
        echo -e "#${RESET} $host ${GREEN}.melisse.org${RESET}"
        echo -e "${ORANGE}#-------- git pull -------${RESET}"

        echo_and_ssh "${host}.melisse.org" "sudo git -C /etc/nixfiles/ config pull.ff only"
        echo_and_ssh "${host}.melisse.org" "sudo git -C /etc/nixfiles/ pull"

        echo -e "${ORANGE}#-------- nixos-rebuild switch -------${RESET}"

        echo_and_ssh "${host}.melisse.org" "sudo /etc/nixfiles/nixos-rebuild.sh ${ACTION}"
    fi
done
