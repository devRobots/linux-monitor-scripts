#!/bin/bash
#title: watcher.sh 
#description: Este script monitorizara la informacion de multiples archivos
#author: Yesid Shair Rosas Toro
#author: Luisa Fernanda Cotte Sanchez
#author: Cristian Camilo Quiceno Laurente
#version: 1.0

#archivo con la lista de archivos a monitorear
ARCHIVOS=$(cat $1)

#Funcion Moniterear
function monitorear()
{
    #Informacion del archivo al momento de iniciar el monitoreo
    STAT=$(stat $1 2>&1 | head -1 )
    
    #Fecha de acceso al archivo al momento de iniciar el monitoreo
    ACCESO=$(stat $1 2>/dev/null | tail -4 | head -1)

    #Fecha Modificacion del archivo al momento de iniciar el monitoreo
    MODIFICACION=$(stat $1 2>/dev/null | tail -4 | head -2| tail -1)
    
    #Se ejecutara por siempre
    while :
    do
        EVENTO=0 #Identifica que modificacion se presenta en el archivo
        NUEVO_STAT=$(stat $1 2>&1| head -1) #Primera linea actual
        NUEVO_ACCESO=$(stat $1 2>/dev/null | tail -4 | head -1) #Acceso actual
        NUEVO_MODIFICACION=$(stat $1 2>/dev/null | tail -4 | head -2| tail -1) #Modificacion actual

        if [ "$NUEVO_STAT" != "$STAT" ] #Verificar si la primera linea cambio
        then
            #miramos cuantos stat hay en la primera linea
            if [ 0 -ne $(echo $NUEVO_STAT  | grep ^stat | wc -l ) ] 
            then
                EVENTO=2 #Borrado
            else
                EVENTO=1 #creación
            fi
            #Actualizamos los valores
            STAT=$NUEVO_STAT 
            ACCESO=$NUEVO_ACCESO 
            MODIFICACION=$NUEVO_MODIFICACION
        else
            if [ "$NUEVO_ACCESO" != "$ACCESO" ] #Comparamos el Acceso actual con el primero
            then
                ACCESO=$NUEVO_ACCESO
                EVENTO=3 #Lectura
            fi

            if [ "$NUEVO_MODIFICACION" != "$MODIFICACION" ] #Comparamos la modificacion actual con el primero
            then
                MODIFICACION=$NUEVO_MODIFICACION
                EVENTO=4 #escritura
            fi
        fi

        #Verifica si hubo alguna modificacion en el archivo
        if [ $EVENTO -ne 0 ]
        then 
            MENSAJE="" #Mensaje que saldra en la notificacion
            LOG_FILE=notificacion.log #Nombre del archivo.log
            FECHA=$(date) #Fecha actual
            if [ ! -e LOG_FILE ]
            then
                # Si el archivo no existe entonces lo crea
                touch $LOG_FILE
            fi

            #Asignar mensaje dependiendo del evento
            case $EVENTO in
                1) MENSAJE="Se creo el archivo $1";; #creación
                2) MENSAJE="Se borro el archivo $1";; #Borrado
                3) MENSAJE="Se leyo el archivo $1";; #Lectura
                4) MENSAJE="Se escribio el archivo $1";; #escritura
            esac

            notify-send --icon=messagebox_info "$MENSAJE" #Notificar el archivo con su modificacion
            echo $FECHA $MENSAJE >> $LOG_FILE #Agregamos el mensaje con la fecha en el archivo.log
        fi
        #Espera unos segundos para que la maquina no este literalmente ejecutando esto todo el tiempo y se muera
        sleep 2
    done
}


#Ejecutar monitorear en cada linea del archivo
for LINEA in $ARCHIVOS
do 
    monitorear $LINEA & #aplicamos paralelismo para usar la funcion en todos los archivos
done
