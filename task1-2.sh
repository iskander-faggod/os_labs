#!/usr/bin/env zsh

#Вывести в файл список PID всех процессов, которые были запущены командами, расположенными в /sbin/

if [ "$(id -u)" != 0 ]
then
    echo "Требуются права root" >&2
    exit 1
fi

:> task1_2_answer

for pid in $(ps -axo pid | tail -n +2)
do
    if [[ -r /proc/$pid/exe ]]
    then
        cat /proc/$pid/cmdline | grep "/sbin" | echo $pid >> task1_2_answer
    fi
done


# cat /proc/$i/cmdline - ссылка на полный исполняемый файл
# :> - очистка файла
# $(ps -axo pid | tail -n +2) - идем по всем процессам -ax(все процессы) -o(выводим столбец определенный) со второй строки