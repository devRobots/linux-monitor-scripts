#!/bin/bash
#title: cpu.sh 
#description: Este script monitorizara el uso de la CPU. 
#author: Yesid Shair Rosas Toro
#author: Luisa Fernanda Cotte Sanchez
#author: Cristian Camilo Quiceno Laurente
#version: 1.1  

# Obtiene todos los campos de informacion sobre uso de la CPU
CPUS_INFO=$(cat /proc/stat | grep ^cpu | head -1 | cut -d" " -f3-)

# Obtiene el campo de informacion sobre uso de la CPU del usuario
USER_INFO=$(echo $CPUS_INFO | cut -d" " -f1)

# Obtiene el nombre del proceso de mayor consumo de CPU
PROCESO=$(ps -Ao comm --sort=-pcpu | tail +2 | head -1)

# Calculo del porcentaje de uso de la CPU
SUM=0
for DATA in $CPUS_INFO
do
	# Realiza la sumatoria de todos los campos de informacion de la CPU
	SUM=$(($SUM+$DATA))
done
# El porcentaje de uso de la CPU se calcula: (user_info*100)/SUM(cpu_info)
CPU_AVG=$(echo "scale=2; ($USER_INFO*100)/$SUM" | bc)

# Verifica si el uso de la CPU es excesivo
if [ $(echo "$CPU_AVG >= 80.00" | bc -l) -eq "1" ]
then
	# Construye el mensaje que se enviara como notificacion
	MENSAJE_NOTIFICACION="El uso de CPU es excesivo: $CPU_AVG%
	PID PROCESO de mayor consumo: $PROCESO"

	# Envia un mensaje de notificacion persistente
	notify-send MENSAJE_NOTIFICACION -u critical
fi

# Verifica que exista el archivo LOG
LOG_FILE=cpu.log
if [ ! -e LOG_FILE ]
then
	# Si el archivo no existe entonces lo crea
	touch $LOG_FILE
fi

# Obtiene la hora actual para el log
FECHA=$(date | cut -d" " -f2,4,5)

# Construye el mensaje que se agregara al LOG
MENSAJE="Fecha: $FECHA; Uso del CPU: $CPU_AVG%; Proceso de mayor consumo: $PROCESO"

# Concatena el mensaje en el archivo LOG
echo $MENSAJE >> $LOG_FILE

