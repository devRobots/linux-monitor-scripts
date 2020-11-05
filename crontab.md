# Crontab

## Punto 1. 

Ejecuta cada cinco minutos el script de monitoreo de **CPU**

```bash
*/5 * * * * /home/$USER/cpu.sh
```

## Punto 2. 

Ejecuta cada dos minutos el script de monitoreo de **RAM**

```bash
* * * * * /home/$USER/ram.sh
```

## Punto 4. 
Ejecuta el script **/home/maria/analizarDisco.sh** cada 10 minutos los días lunes a viernes de 7:00 am a 2:00 pm.

```bash
* * * * * /home/maria/analizarDisco.sh
```

## Punto 5. 
Ejecuta el script **/home/jose/analizarMemoria.sh** todos los domingos del primer trimestre de
2021 cada 15 minutos de 8:00 pm a 11:00 pm.

```bash
* * * * * /home/jose/analizarMemoria.sh
```