#!/usr/bin/env bash

# include util functs
source ./_shared/util.sh
source ./_shared/repo.sh
source ./_shared/UI.sh

main() {
    log head "remove" "looking for previous installations & configs"

    if [ "$(php_installed)" = "1" ]; then

        log info "load repository list"
        remi=$(get_installed_remi_repos)
        if [[ $remi != "" ]]; then
            repo_disable "$remi"
        fi

        v=$(only_digits "$(get_php_version)")
        v="$v $(echo $remi | grep -o "php[0-9]\+" | sed "s/[^0-9 ]//g")"

        if [ "$v" != "" ]; then
            while IFS=' ' read -ra ADDR; do
                for i in "${ADDR[@]}"; do
                    # process "$i"
                    modules=$(./php/lib/modules.sh $i)
                    line="yum -y remove php php-* php$i $modules"
                    instr "$line" "deleting php $i & co.."
                done
            done <<< "$v"
        else
            line="yum -y remove php php-*"
            instr "$line" "deleting php & co.."
        fi

        line="yum clean all"
        instr "$line" "clearing repository cache"
        log emote " swoosh "
    fi

    log info "machine is PHP-sanitized"
}

main
