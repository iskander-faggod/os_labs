#!/usr/bin/env zsh

#Используя псевдофайловую систему /proc найти процесс, которому выделено больше всего
#оперативной памяти. Сравнить результат с выводом команды top.

# declare => указание типа для переменной (-i => int)
declare -i max
declare -i ans

# проходимся по pid в полном списке процессов начиная с второй строки (sed 1d)
for pid in $(ps -axo pid | tail -n +2)
do
        # проверка на то, что в папке status что-то лежит под этим pid
        if [[ -r /proc/$pid/status ]]
        then
                # записываем в переменую кол-во затраченной памяти на проект
                memory=$(grep -s "VmHWM" /proc/$pid/status | awk '{print $2}')
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
echo "top max pid $(top -b -n 1 | tail -n +8 | sort -n -r -k 10 | head -1 | awk '{print $1}')"