#!/usr/bin/env zsh

# для перезаписи в файл
:> file
# проходимся по всем pid | начинаем со второй строчки, поскольку первая не хранит нужной информации (шапка таблицы)
for pid in $(ps -Ao pid | tail +2)
do
        # проверка на то, что в папках status и sched что-то лежит под этим pid
        if [[ -r /proc/$pid/status && -r /proc/$pid/sched ]]
        then
                # записываем данные в переменные через grep
                PPid=$(grep -s -E "^PPid" /proc/$pid/status | awk '{print $2}')
                sum_exec_runtime=$(grep -s -E "^se.sum_exec_runtime" /proc/$pid/sched | awk '{print $3}')
                nr_switches=$(grep -s -E "^nr_switches" /proc/$pid/sched | awk '{print $3}')
        fi
        # если значение nr_switches не пустая строка
        if [[ ${nr_switches} -ne "" ]]
        then
                # считаем ART по формуле и выводим с точною 20 знаков после запятой (bc -l)
                ART=$(echo "${sum_exec_runtime} / ${nr_switches}" | bc -l)
                echo $pid $PPid $ART >> file
        fi
done

# сортироум данные по ppid в файле
sort -n -k 2 file > file2

# если у нас одинаковый  индификатор родительского процесса вставляем строку
echo "$(awk 'NR == FNR {count[$2]++; ppid[$2]=$2; sum[$2]+=$3; next } { print "ProcessID="$1" : Parent_ProcessID="$2" : Average_Running_Time="$3" : Average_Running_Children_of_P>
