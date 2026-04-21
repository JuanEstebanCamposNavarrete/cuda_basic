Este proyecto es una convolucion aplicada a un archivo binario de 1D.

Dentro del proyecto se encuentran 3 funciones en donde se ejecuta la misma convolucion al mismo archivo por 3 medios diferentes:
1: HOST (CPU)
2: DEVICE (GPU shared) memoria compartida
3: DEVICE (GPU native) memoria global
Despues de hacer realizar las operaciones en cada caso, se ejecuta una comparacion entre los 3 archivos para comparar diferencias.

Para ejecutar el proyecto facilmente se puede usar el archivo MAKE que contiene instrucciones para manipular el proyecto

Debe ingresar a la carpeta principal en una terminal (convolucion_1D) y debe usar el comando "make help".
