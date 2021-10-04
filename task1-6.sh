#!/usr/bin/env zsh

# declare => указание типа для переменной (-i => int)
declare -i max
declare -i ans

# проходимся по pid в полном списке процессов начиная с второй строки (sed 1d)
for pid in $(ps aux | awk '{print $2}' | sed "1d")
do
        # проверка на то, что в папке status что-то лежит под этим pid
        if [[ -r "/proc/${pid}/status" ]]
        then
                # записываем в переменую кол-во затраченной памяти на проект
                memory=$(grep -s "VmHWM" /proc/${pid}/status | awk '{print $2}')
                # проверяем на не пусту строки
                if [[ $memory != "" ]]
                then
                        # если память больше максимального
                        if [[ $memory -gt $max ]]
                        then
                                ans=$pid
                                max=$memory
                        fi
                fi
        fi
done

# вывод
echo "PID:" $ans "Memory:" $max