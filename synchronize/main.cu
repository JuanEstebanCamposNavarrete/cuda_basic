//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// programacion en cuda C/C++
// curso basico
// marzo 2026
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// includes
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
// kernel
__global__ void suma (int *vec1, int *vec_sum, int N){
    //funcion para sumar dos vectores de n elementos
    //kernel de multiples bloques para procesar n datos de vector

    //creo el identificador de cada hilo
    int ID = blockIdx.x * blockDim.x + threadIdx.x;

    //sumo directamente en el vector de suma, mas la inversa del vector 1
    //verificamos con un if, que no se ecceda el numero de hilos para el numero de datos
    if(ID<N){
        vec_sum[ID] = vec1[ID] + vec1[N - 1 - ID];
    }
}

void opt(int dat, int *bloc, int *thre){

    //ya me estoy llendo pero aqui calculo la cantidad optima de hilos y bloques para cada caso
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//aqui va la funcion principal despues de crear el kernel

int main(){

    //aqui declaro los punteros y la cantidad de datos de cada vector
    int *hst_vec1, *hst_vecsum;
    int *dev_vec1, *dev_vecsum;

    //pruebo con un array de enteros de diferentes valores para verificar los tiempos de ejecucion en cada caso
    int val[] = {
        //todos los valores manejados aqui dentro seran de tiempo int, las operaciones se manejaran en 4 bytes 
        1 << 5, // esto es 2 elevado a la 5 = 32 elementos enteros, 32 * 4 bytes es 128 bytes, y 128 * 8 son 1024 bits
        1 << 8, // 256 elementos
        1 << 10, // 1024 elementos
        1 << 12,  // 4096 elementos
        1 << 14,  // 16384 elementos
        1 << 16,  // 65536 elementos
        1 << 18,  // 262144 elementos
        1 << 20,  // 1048576 elementos
        1 << 22,  // 4194304 elementos
        1 << 24   // 16777216 elementos

        //el limite seguro es de exponente 31, son 2147 millones de elementos, pero es mejor usar datos unsigned, 1U << 31
    };
    //especificamos el tama;o del array
    int tam = sizeof(val)/sizeof(val[0]);
    //el tama;o es el numero de datos dentro en bytes(10*4), sobre el tama;o del primer dato en bytes(4), todo del tipo de dato entero, tam = (10*4)/(4) = 10
    
    //se crean las variables para medir el tiempo usando las funciones de cuda
    //primero creamos las variables te tipo puntero a un nodo en el buffer del controlador
    cudaEvent_t start, stop;
    //usamos los punteros que apuntan a basura actualemtne para que apunten a los nodos que voy a llenar
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //comenzamos a iterar sobre los elementos del array
    for(int i = 0; i < tam; i++){
        //variable que contiene los datos iterados del array
        int N = val[i];
        //en este caso al usar valores grandes, tengo que usar el tipo de dato size_t, que representa tama;os en forma de bytes, para no tener problemas
        size_t bytes = N * sizeof(int);
        //guarda el tama;o en la variable, del valor iterado multiplicado por el tipo de datos que es (int 4 bytes * millones de elementos)

        //es mi primer programa de este tipo, para visualizarlo imprimo la informacion que me ayuda a entenderlo
        printf("\n\n\n");
        printf("son %d elementos y el tama;o en megabytes es", N, bytes / (1024 * 1024));
        printf("\n\n\n");
        //divido la cantidad total de bytes entre la cantidad de bytes que hay en un megabyte (x/(1024*1024))

        //una vez establecido el tama;o que necesito, y declaradas las variables, puedo apartar el espacio en memoria necesario
        //memoria en el host

        //comodeclare los punteros fuera del bucle, tengo que liberar la memoria antes de volverla a asignar
        if(hst_vec1 != NULL){
            free(hst_vec1);
        }
        if(hst_vecsum != NULL){
            free(hst_vecsum);
        }
        if (dev_vec1 != NULL){
            cudaFree(dev_vec1);
        }
        if(dev_vecsum != NULL){
            cudaFree(dev_vecsum);
        }
        //mucho codigo, la suguiente lo declaro dentro del bucle
        //apenas empiezo a ver como se manejan los errores al reservar la memoria

        hst_vec1 = (int*)malloc(bytes);
        hst_vecsum = (int*)malloc(bytes);

        if(!hst_vec1 || !hst_vecsum){
            printf("error malloc para %d", N);
            break;
        }

        //asignamos el espacio en memoria al mismo tiempo que declaramos la variable de error que se inicializa a la hora de apartar el espacio
        cudaError err = cudaMalloc((void**)&dev_vec1, bytes);
        if(err != cudaSuccess){
        //cudageterror, toma el valor de err para buscar el tipo de error
            printf("error en cudamalloc %s", cudaGetErrorName(err));
            exit(EXIT_FAILURE);

        }
        cudaError err = cudaMalloc((void**)&dev_vecsum, bytes);
        if(err != cudaSuccess){
            printf("error a la hora de apartar memoria en cuda %s", cudaGetErrorName(err));
            exit(EXIT_FAILURE);
        } 
        //los errores a la hora de apartar memoria normalmente ocurren cuando la memoria esta completamente llena, lo mejor es terminar el proceso

        //una vez apartada la memoria, puedo inicializarla
        for(int i = 0; i < N; i++){
            //el puntero con N datos se inicializa en cada posicion
            hst_vec1[i] = i + 1;
        }
        //esto podria ser un problema, ya que la gpu esta esperando a que la cpu inicialize los datos, mas adelante inicializre la cpu antes de apartar espacio en gpu

        //una vez inicializada tengo que transferir los datos a la gpu, al mismo tiempo comienzo a medir el tiempo
        cudaEventRecord(start);
        cudaMemcpy(dev_vec1, hst_vec1, N, cudaMemcpyHostToDevice);
        cudaEventRecord(stop);
        //las variables guardan el flag de cada momento para medir la diferencia y saber el tiempo
        float t1; // variable que guarda el primer tiempo medido
        cudaEventElapsedTime(&t1, start, stop);
        //esta funcion calcula el tiempo en milisegundost1, start, stop);
        //esta funcion calcula el tiempo en milisegundos
        
        /*
        En esta parte del codigo tuve que desciarme, me di cuenta de que necesitaba
        calcular el uso optimo de los recursos de mi gpu.

        Para los datos del array, que van desde 32 elementos, hasta varios millones de ellos
        tuve que comenzar a buscar informacion sobre como funcionan las restricciones
        y la optimizacion de recursos en la gpu, ahi me tope con varios problemas de optimizacion,
        uso de memoria, limites fisicos y demas cosas.

        este codigo espagueti queda como primera prueba en donde trato de optimizar los recursos
        de mi gpu para cada caso de N datos

        puede que no sea perfecto pero es el primer acercamiento que he tenido con este tipo de problemas
        ya que hasta ahora no habia trabajado con procesamiento de datos en paralelo

        Para esto he extraido las caracteristicas de la gpu de mi laptop, con las cuales pienso crear una funcion
        para calcular cuantos hilos y cuantos bloques puedo usar de forma optima.

        //////////////////////////////
        nombre comercial: 
        NVIDIA GeForce GTX 1650 

        version de compute capability: 
        7.5

        streaming multiprocessor: 
        14 

        maximo de hilos por SM: 
        1024 

        maximo de bloques por SM: 
        16

        maximo de hilos por bloque: 
        1024

        maximo de registros por SM:
        65536

        memoria compartida por bloque:
        48.00 KB

        warps maximos por SM
        32

        warps maximos por bloque:
        32

        maximo de bloques en dada dimencion
        (x:2147483647, y:65535, z:65535)

        maximo de hilos por bloque en cada dimencion:
        (x:1024, y:1024, z:64)

        RAM en GPU
        3.63 GB

        memoria total constante (para lectura de constantes):
        64.00 KB

        cuantos kernels puedo lanzar a la vez:
        1

        motores asincronos para copias de datos:
        3

        //////////////////////////////

        */


        //funcion para optimizar los recursos


    }   
    
    return 0;
}