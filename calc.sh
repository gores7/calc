#!/bin/bash

log_error() {
    echo "$(date): $1" >> "$log_file"
    echo "$1" >&2
    echo "Использование: $0 -o <операция> -n \"<числа>\" -l <файл_логов>"
    exit 1
}

while getopts "o:n:l:" opt; do
    case $opt in
        o) operation=$OPTARG ;;
        n) numbers=$OPTARG ;;
        l) log_file=$OPTARG ;;
        *) log_error "Неверный аргумент, используйте [-o|-n|-l]" ;;
    esac
done

[ -z $operation ] && log_error "Не указана операция"
[ -z $numbers ] && log_error "Не указаны числа"
[ -z $log_file ] && log_error "Не указан файл логов"

case $operation in
    sum|sub|mul|div|pow) ;;
    *) log_error "Ошибка: неверная операция '$operation'. Допустимые: sum, sub, mul, div, pow" ;;
esac

read -ra num_array <<< $numbers

if [ $operation -eq "pow" ]; then
    [ ${#num_array[@]} -ne 2 ] && log_error "Для pow требуется ровно два числа"
else
    [ ${#num_array[@]} -lt 2 ] && log_error "Для $operation требуется минимум два числа"
fi

calculate() {
    local op=$1
    shift
    local numbers=($@)
    local result=${numbers[0]}

    case $op in
        sum)
            for num in ${numbers[@]:1}; do
                result=$((result + num))
            done ;;
        sub)
            for num in ${numbers[@]:1}; do
                result=$((result - num))
            done ;;
        mul)
            for num in ${numbers[@]:1}; do
                result=$((result * num))
            done ;;
        div)
            for num in ${numbers[@]:1}; do
                [[ $num -eq 0 ]] && log_error "Деление на ноль невозможно"
                result=$((result / num))
            done ;;
        pow)
            result=$((numbers[0] ** numbers[1])) ;;
    esac
    echo "Результат: $result"
}

for num in ${num_array[@]}; do
    if ! [[ $num =~ ^-?[0-9]+$ ]]; then
        log_error "Некорректное число: $num"
    fi
done

calculate $operation ${num_array[@]}               
