#!/bin/bash

cpus_info=$(cat /proc/stat | grep ^cpu | head -1 | cut -d" " -f3-)
idle_info=$(echo $cpus_info | cut -d" " -f3)
proceso=$(ps -Ao comm --sort=-pcpu | tail +2 | head -1)

sum=0
for data in $cpus_info
do
	sum=$(($sum+$data))
done
average=$(echo "scale=2; ($idle_info*100)/$sum" | bc)

if [ $(echo "$average >= 80.00" | bc -l) -eq "1" ]
then
	notify-send "El uso de CPU es excesivo: $average%\nPID proceso de mayor consumo: $proceso" -u critical
fi

log_file=cpu.log
if [ ! -e log_file ]
then
	touch $log_file
fi

fecha=$(date | cut -d" " -f2,4,5)
mensaje="Fecha: $fecha; Uso del CPU: $average%; Proceso de mayor consumo: $proceso"
echo $mensaje >> $log_file

