#!/bin/bash

#Написать скрипт, определяющий три процесса, которые за 1 минуту, прошедшую с момента запуска
#скрипта, считали максимальное количество байт из устройства хранения данных. Скрипт должен
#выводить PID, строки запуска и объем считанных данных, разделенные двоеточием.

# массивы для считывания начальных и конечных данных
start_data=()
end_data=()

# массивы для вывода pid и строк запуска
pids=()
cmdline=()

# для перезаписи файла
:> task7.txt

# проходимся по всем pid из полного списка процессов
for pid in $(ps -axo pid | tail -n +2)
do
        # проверка на то, что в папке io что-то лежит под этим pid
        if [[ -r /proc/$pid/io ]]
        then
                # считываем стартовые данные
                start_data[$pid]=$(grep -s "rchar" /proc/$pid/io | awk '{print $2}')
                pids[$pid]=$pid
                cmdline[$pid]=$(cat /proc/$pid/cmdline | tr -d '\0') # tr-d - удаляем \0
        fi
done

# останавливаемся на 60 секунд
sleep 10

# проходимся по всем pid и считывем конечные данные
for pid in "${pids[@]}" # pids[@]-весь массив pids
do
        end_data[$pid]=$(grep -s "rchar" /proc/$pid/io | awk '{print $2}')
done

# проходимся по всем pid и высчитываем и считаем максимальное количество байт из устройства хранения данных
for pid in "${pids[@]}"
do
        diff=$(echo "${end_data[$pid]} - ${start_data[$pid]}" | bc)
        echo $pid $diff ${cmdline[$pid]} >> task7.txt
done

sort -n -r -k 2 task7.txt | head -3 | awk '{print $1":"$2":"$3}'