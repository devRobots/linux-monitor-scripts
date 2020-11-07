#!/bin/bash
#title: watcher.sh 
#description: Este script monitorizara la informacion de multiples archivos
#author: Yesid Shair Rosas Toro
#author: Luisa Fernanda Cotte Sanchez
#author: Cristian Camilo Quiceno Laurente
#version: 1.0

#archivo txt con los archivos a monitorear
ARCHIVO=$(cat $1)

#Funcion Moniterear
function monitorear()
{
    STAT=$(stat $1 2>&1 | head -1 )
    ACCESO=$(stat $1 2>/dev/null | tail -4 | head -1)
    MODIFICACION=$(stat $1 2>/dev/null | tail -4 | head -2| tail -1)
    
    while :
    do
        #creación,borrado, lectura y escritura
        EVENTO=0
        NUEVO_STAT=$(stat $1 2>&1| head -1)
        NUEVO_ACCESO=$(stat $1 2>/dev/null | tail -4 | head -1)
        NUEVO_MODIFICACION=$(stat $1 2>/dev/null | tail -4 | head -2| tail -1)

        if [ "$NUEVO_STAT" != "$STAT" ]
        then
            if [ 0 -ne $(echo $NUEVO_STAT  | grep ^stat | wc -l ) ]
            then
                EVENTO=2
            else
                EVENTO=1
            fi
            STAT=$NUEVO_STAT
            ACCESO=$NUEVO_ACCESO
            MODIFICACION=$NUEVO_MODIFICACION
        else
            if [ "$NUEVO_ACCESO" != "$ACCESO" ]
            then
                ACCESO=$NUEVO_ACCESO
                EVENTO=3
            fi

            if [ "$NUEVO_MODIFICACION" != "$MODIFICACION" ]
            then
                MODIFICACION=$NUEVO_MODIFICACION
                EVENTO=4
            fi
        fi

        #Crear archivo.log
        if [ $EVENTO -ne 0 ]
        then 
            MENSAJE=""
            LOG_FILE=notificacion.log
            FECHA=$(date)
            if [ ! -e LOG_FILE ]
            then
                # Si el archivo no existe entonces lo crea
                touch $LOG_FILE
            fi

            case $EVENTO in
                1) MENSAJE="Se creo el archivo $1";; #creación
                2) MENSAJE="Se borro el archivo $1";; #Borrado
                3) MENSAJE="Se leyo el archivo $1";; #Lectura
                4) MENSAJE="Se escribio el archivo $1";; #escritura
            esac

            notify-send --icon=messagebox_info "$MENSAJE"
            # archivo log que incluya fecha, hora, evento y nombre del archivo
            # Concatena el mensaje en el archivo LOG
            echo $FECHA $MENSAJE >> $LOG_FILE
        fi

        sleep 2
    done
}


#Obtener lista de los archivos
for LINEA in $ARCHIVO
do 
    monitorear $LINEA &
done
