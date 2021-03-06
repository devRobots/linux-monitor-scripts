#!/bin/bash
#title: ram.sh 
#description: Este script monitorizara el uso de la RAM. 
#author: Yesid Shair Rosas Toro
#author: Luisa Fernanda Cotte Sanchez
#author: Cristian Camilo Quiceno Laurente
#version: 1.0

# Obtiene el valor total de la memoria RAM
MEM_TOTAL=$(free -m | head -2 | tail -1 | awk '{ print $2 }')
# Obtiene el valor usado de la memoria RAM 
MEM_USED=$(free -m | head -2 | tail -1 | awk '{ print $3 }')
# Convierte el valor usado de la memoria RAM en porcentaje
MEM_PORC=$(echo "scale=2; ($MEM_USED*100)/$MEM_TOTAL" | bc)
# Obtiene el nombre el nombre del proceso con mayor consumo de RAM
PROCESO=$(ps aux | awk '{print $2, $4, $11}' | sort -k2r | head -n 2 | tail -1 | cut -d" " -f3)
# Mensaje de advertencia que muestra el porcentaje de la memoria RAM usada y el nombre del proceso
MSG="Advertencia: RAM: $MEM_PORC% Proceso: $PROCESO"

# Verifica que exista el archivo LOG
LOG_FILE=ram.log
if [ ! -e LOG_FILE ]
then
	# Si el archivo no existe entonces lo crea
	touch $LOG_FILE
fi

EVENTO=0

# Verifica si el porcentaje de memoria RAM está entre el rango de 75.00% y 100.00%
if [ $(echo "$MEM_PORC >= 75.00 && $MEM_PORC <= 100.00" | bc -l) -eq "1" ] 
then
    # Ícono de error
    notify-send "$MSG" --icon=messagebox_critical -u critical
    EVENTO=1
else
    # Verifica si el porcentaje de memoria RAM está entre el rango de 50.00% y 74.99%
    if [ $(echo "$MEM_PORC >= 50.00 && $MEM_PORC < 75.00" | bc -l) -eq "1" ]
    then
        # Ícono de advertencia
        notify-send "$MSG" --icon=messagebox_warning -u critical
        EVENTO=2
    fi
fi

# Obtiene la hora actual para el log
FECHA=$(date)

# Nombre de evento para mostrar en pantalla dependiendo del caso en función del EVENTO
case $EVENTO in
    1) NOM_EVENTO="[CRITICO] RAM: $MEM_PORC% Proceso: $PROCESO";;
    2) NOM_EVENTO="[ADVERTENCIA] RAM: $MEM_PORC%";;
esac

# Construye el mensaje que se agregara al LOG
if [ $EVENTO -ne 0 ] 
then
    LOG_MSG="$FECHA $NOM_EVENTO"

    # Concatena el mensaje en el archivo LOG
    echo $LOG_MSG >> $LOG_FILE
fi