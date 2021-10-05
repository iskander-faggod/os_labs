#!/usr/bin/env zsh

# на вход имя процесса -  возвращаем пид этого процесса,  если нет то "такого процесса нет"
read cmdline
  for pid in $(ps -axo pid)
  do  
     if [[ -r /proc/$pid/cmdline ]] 
     then
         cmd=$(cat /proc/$pid/cmdline | tr -d '\0')
         if [[ $cmd == $cmdline ]]
         then
             echo $pid
             exit 0
         fi
     fi
 done
 
 echo "такого процесса нет"