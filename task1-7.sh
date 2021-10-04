#!/bin/bash

# массивы для считывания начальных и конечных данных
start_date=()
end_data=()
# массивы для вывода pid и строк запуска
pids=()
cmdline=()

# для перезаписи файла
:> task7.txt

# проходимся по всем pid из полного списка процессов
for pid in $(ps -e -o pid)
do
        # проверка на то, что в папке io что-то лежит под этим pid
        if [[ -r /proc/$pid/io ]]
        then
                # считываем стартовые данные
                strat_date[$pid]=$(grep "rchar" /proc/$pid/io | awk '{print $2}')
                pids[$pid]=$pid
                cmdline[$pid]=$(cat /proc/$pid/cmdline | tr -d '\0')
        fi
done

# остонавливаемся на 60 секунд
sleep 60

# проходимся по всем pid и считывем конечные данные
for pid in "${pids[@]}"
do
        end_data[$pid]=$(grep "rchar" /proc/$pid/io | awk '{print $2}')
done

# проходимся по всем pid и высчитываем и считаем максимальное количество байт из устройства хранения данных
for pid in "${pids[@]}"
do
        diff=$(echo "#{end_data[$pid]} - ${start_data[$pid]}" | bc)
        echo $pid $diff ${cmdline[$pid]} >> task7.txt
done

sort -n -r -k 2 task7.txt | head -n -3 | awk '{print $1":"$2":"$3}'