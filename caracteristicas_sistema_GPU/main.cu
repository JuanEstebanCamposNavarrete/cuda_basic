////////////////////////////////////////////////////////////////////////////////////////////////////
// programacion en C/C++ cuda
// marzo 2026
// Programa para extraer las caracteristicas de mi sistema
////////////////////////////////////////////////////////////////////////////////////////////////////
// incudes
#include <cuda_runtime.h>
#include <stdio.h>
//
// funcion principal main
int main(){

    //declaro una variable que contenga la cantidad de GPU en sistema
    int con;
    //le doy la direccion de memoria
    cudaError_t err = cudaGetDeviceCount(&con);

    if(err != cudaSuccess){
        printf("Error al obtener dispositivos %s", cudaGetErrorString(err));
        return 1;
    }

    if(con == 0){
        printf("No se encontraron GPU compatible con CUDA\n");
        return 1;
    }

    //una vez declarado itero sobre la cantidad de gpu en sistema para extraer las caracteristicas de cada una
    for (int i = 0; i < con; i++){

        //un dato de este tipo es un struct que contiene las caracteristicas de la gpu organizadas
        cudaDeviceProp prop;

        //esta funcion extrae las caracteristicas y las almacena en el struct
        cudaGetDeviceProperties(&prop, i);

        //las caracteristicas ahora estan dentro de la variable prop
        //tengo que exxtraerlas y mostrarlas de forma ordenada
        printf("//////////////////////////////\n");
        printf("nombre comercial: \n");
        printf("%s \n\n", prop.name);
        printf("version de compute capability: \n");
        printf("%d.%d\n\n", prop.major, prop.minor);
        printf("streaming multiprocessor: \n");
        printf("%d \n\n", prop.multiProcessorCount);
        printf("maximo de hilos por SM: \n");
        printf("%d \n\n", prop.maxThreadsPerMultiProcessor);
        printf("maximo de bloques por SM: \n");
        printf("%d\n\n", prop.maxBlocksPerMultiProcessor);
        printf("maximo de hilos por bloque: \n");
        printf("%d\n\n", prop.maxThreadsPerBlock);
        printf("maximo de registros por SM:\n");
        printf("%d\n\n", prop.regsPerMultiprocessor);
        printf("memoria compartida global:\n");
        printf("%.2f KB\n\n", prop.sharedMemPerBlock/1024.0);
        printf("warps maximos por SM\n");
        printf("%d\n\n", prop.maxThreadsPerMultiProcessor/32);
        printf("warps maximos por bloque:\n");
        printf("%d\n\n", prop.maxThreadsPerBlock /32);
        printf("maximo de bloques en dada dimencion\n");
        printf("(x:%d, y:%d, z:%d)\n\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
        printf("maximo de hilos por bloque en cada dimencion:\n");
        printf("(x:%d, y:%d, z:%d)\n\n", prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);
        printf("RAM en GPU\n");
        printf("%.2f GB\n\n", prop.totalGlobalMem/(1024.0*1024.0*1024.0));
        printf("memoria total constante (para lectura de constantes):\n");
        printf("%.2f KB\n\n", prop.totalConstMem/1024.0);
        printf("cuantos kernels puedo lanzar a la vez:\n");
        printf("%d\n\n", prop.concurrentKernels);
        printf("motores asincronos para copias de datos:\n");
        printf("%d\n\n", prop.asyncEngineCount);

        int clockRate;
        int memoryClockRate;
        
        // Obtener frecuencia del GPU
        cudaDeviceGetAttribute(&clockRate, cudaDevAttrClockRate, i);
        // Obtener frecuencia de la memoria
        cudaDeviceGetAttribute(&memoryClockRate, cudaDevAttrMemoryClockRate, i);
        
        printf("frecuencia de GPU en kHz:\n");
        printf("%.2f GHz\n\n", clockRate / 1000000.0);
        printf("frecuencia de la memoria:\n");
        printf("%.2f GHz\n\n", memoryClockRate / 1000000.0);

        printf("//////////////////////////////\n");

    }
    
    return 0;
}