# Convolución 1D en archivo binario

Este proyecto implementa una convolución aplicada a un archivo binario de 1D.

## Descripción

Dentro del proyecto se ejecutan las mismas operaciones de convolución sobre el mismo archivo por tres medios diferentes:

1. **HOST (CPU)**.
2. **DEVICE (GPU shared)** usando memoria compartida.
3. **DEVICE (GPU native)** usando memoria global.

Después de realizar las operaciones en cada caso, se ejecuta una comparación entre los archivos generados para analizar las diferencias.

## Estructura del proyecto

- `convolucion_1D/`
- `convolucion_1D/src/`
- `convolucion_1D/include/`
- `convolucion_1D/data/`

## Ejecución

Para ejecutar el proyecto de forma sencilla, se utiliza el archivo `Makefile`, que contiene instrucciones para compilar y manipular el proyecto.

### Comandos

1. Abre una terminal en la carpeta principal del proyecto:
   ```bash
   cd convolucion_1D
   ```

2. Consulta las opciones disponibles:
   ```bash
   make help
   ```

## Objetivo

El objetivo del proyecto es comparar el comportamiento y el resultado de la convolución al implementarla en CPU y en GPU con diferentes enfoques de memoria.

## Notas

- El archivo binario de entrada se procesa dentro del proyecto.
- Los resultados generados pueden compararse para observar diferencias entre las implementaciones.
