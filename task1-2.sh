#!/usr/bin/env zsh

# you root?
if [ "$(id -u)" != 0 ]
then
    echo "Требуются права root" >&2
    exit 1
fi

:> task1_2_answer

for i in $(ls /proc/ | grep -E "[0-9]+")
do
    echo $i | readlink /proc/$i/exe | grep "/sbin" | echo $i >> task1_2_answer
done


# readlink /proc/$i/exe - ссылка на полный исполняемый файл
# :> - очистка файла
