# Crontab

## Punto 1. 

Ejecuta cada cinco minutos el script de monitoreo de **CPU**

```bash
*/5 * * * * ./cpu.sh
```

## Punto 2. 

Ejecuta cada dos minutos el script de monitoreo de **RAM**

```bash
*/2 * * * * ./ram.sh
```

## Punto 4. 
Ejecuta el script **/home/maria/analizarDisco.sh** cada 10 minutos los días lunes a viernes de 7:00 am a 2:00 pm.

```bash
*/10 7-14 * * 1-5 /home/maria/analizarDisco.sh
```

## Punto 5. 
Ejecuta el script **/home/jose/analizarMemoria.sh** todos los domingos del primer trimestre de
2021 cada 15 minutos de 8:00 pm a 11:00 pm.

```bash
*/15 20-23 * 1-3 0 /home/jose/analizarMemoria.sh 
```