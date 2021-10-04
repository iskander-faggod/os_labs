#!/usr/bin/env zsh

# для перезаписи в файл
:> file
# проходимся по всем pid | начинаем со второй строчки, поскольку первая не хранит нужной информации (шапка таблицы)
for pid in $(ps -A -o pid | tail +2)
do
        # проверка на то, что в папках status и sched что-то лежит под этим pid
        if [[ -r /proc/$pid && -r /proc/$pid/status && -r /proc/$pid/sched ]]
        then
                # записываем данные в переменные через grep
                PPid=$(grep -s -E "^PPid" /proc/"$pid"/status | awk '{print $2}')
                sum_exec_runtime=$(grep -s -E "^se.sum_exec_runtime" /proc/$pid/sched | awk '{print $3}')
                nr_switches=$(grep -s -E "^nr_switches" /proc/$pid/sched | awk '{print $3}')

                # если значение nr_switches не пустая строка
                # bc -l => калькулятор, точность 20 знаков после запятой
                if [[ ${nr_switches} -ne "" ]]
                then
                        avg_atom=$( echo "$sum_exec_runtime / $nr_switches" | bc -l)
                fi

                echo $pid $PPid $avg_atom >> file
        fi
done

# сортирем их по ppid и вводим в нужном формате
echo "$(sort -n -k 2 file | awk '{print "ProcessID="$1" : Parent_ProcessID="$2" : Average_Running_Time="$3}' | tail +2)" > task4.txt