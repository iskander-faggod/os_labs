#!/bin/bash

#В полученном на предыдущем шаге файле после каждой группы записей с одинаковым
#идентификатором родительского процесса вставить строку вида
#Average_Running_Children_of_ParentID=N is M,
#где N = PPID, а M – среднее, посчитанное из ART для всех процессов этого родителя.

# для перезаписи в файл
:> file
# проходимся по всем pid | начинаем со второй строчки, поскольку первая не хранит нужной информации (шапка таблицы)
for pid in $(ps -axo pid | tail -n +2) #со второй строки
do
        # проверка на то, что в папках status и sched что-то лежит под этим pid
        if [[ -r /proc/$pid/status && -r /proc/$pid/sched ]] # -r - можем прочитать файл
        then
                # записываем данные в переменные через grep
                PPid=$(grep -s -E "^PPid" /proc/"$pid"/status | awk '{print $2}') #Берем $2 - значение Ppid
                sum_exec_runtime=$(grep -s -E "^se.sum_exec_runtime" /proc/$pid/sched | awk '{print $3}') 
                nr_switches=$(grep -s -E "^nr_switches" /proc/$pid/sched | awk '{print $3}')

                # если значение nr_switches не пустая строка
                # bc -l => калькулятор, точность 20 знаков после запятой
                if [[ ${nr_switches} -ne "" ]]
                then
                        avg_atom=$( echo "$sum_exec_runtime / $nr_switches" | bc -l) #в системе процессов определить среднее время непрерывного использования процессора (CPU_burst) и вывести в один файл
                fi

                echo $pid $PPid $avg_atom >> file
        fi
done

sort -n -k 2 file > file2

previous_ppid=0
sum=0
cnt=0

:> answer5

while read -r line
do
    #читаем файл извлекаем нужные столбцы
    ppid=$(echo $line | awk '{print $2}') 
    art=$(echo $line | awk '{print $3}') 

    # если текузий пид == пред пид 
    if [[ $ppid -eq $previous_ppid ]]
    then
        echo $line >> answer5 #строку которую считали
        sum=$(echo "$sum + $art" | bc) #увеличиваем сумму avg_atom
        cnt=$(( $cnt+1 )) #кол-во проццесов у которых одинаковый pid
    else 
        echo "$sum / $cnt" | bc -l >> answer5 # вывод ср.арифм в файлик
        echo $line >> answer5 #добавляем строчку в файл
        sum=$art
        cnt=1
        previous_ppid=$ppid
    fi

done < file2

echo "$sum / $cnt" | bc -l >> answer5



