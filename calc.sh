#!/bin/bash

log_error() {
    echo "$(date): $1" >> "$log_file"
    echo "$1" >&2
    exit 1
}

while getopts "o:n:l:" opt; do
    case $opt in
        o) operation=$OPTARG ;;
        n) numbers=$OPTARG ;;
        l) log_file=$OPTARG ;;
        *) echo "Использование: $0 -o <операция> -n \"<числа>\" -l <файл_логов>"
           log_error "Неверный аргумент" ;;
    esac
done

[ -z "$operation" ] && log_error "Не указана операция"
[ -z "$numbers" ] && log_error "Не указаны числа"
[ -z "$log_file" ] && log_error "Не указан файл логов"

case $operation in
    sum|sub|mul|div|pow) ;;
    *) echo "Ошибка: неверная операция '$operation'. Допустимые: sum, sub, mul, div, pow"
       log_error "Неверная операция: $operation" ;;
esac

read -r -a num_array <<< "$numbers"

if [ "$operation" = "pow" ]; then
    [ ${#num_array[@]} -ne 2 ] && log_error "Для pow требуется ровно два числа"
else
    [ ${#num_array[@]} -lt 2 ] && log_error "Для $operation требуется минимум два числа"
fi

calculate() {
    local op=$1
    shift
    local numbers=("$@")
    local result

    case $op in
        sum)
            result=0
            for num in "${numbers[@]}"; do
                result=$((result + num))
            done ;;
        sub)
            result=${numbers[0]}
            for ((i=1; i<${#numbers[@]}; i++)); do
                result=$((result - numbers[i]))
            done ;;
        mul)
            result=1
            for num in "${numbers[@]}"; do
                result=$((result * num))
            done ;;
        div)
            result=${numbers[0]}
            for ((i=1; i<${#numbers[@]}; i++)); do
                [ "${numbers[i]}" -eq 0 ] && log_error "Деление на ноль"
                result=$((result / numbers[i]))
            done
            ;;
        pow)
            result=$((numbers[0] ** numbers[1])) ;;
    esac
    echo "Результат: $result"
}

for num in "${num_array[@]}"; do
    if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
        log_error "Некорректное число: $num"
    fi
done

calculate "$operation" "${num_array[@]}"