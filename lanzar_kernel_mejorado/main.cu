////////////////////////////////////////////////////////////////////////////////////////////////////
// programacion en cuda c/c++
// curso basico
// marzo 2026
////////////////////////////////////////////////////////////////////////////////////////////////////
// includes
#include <cuda_runtime.h>
#include <stdlib.h>
#include <stdio.h>
// defines
#define hilos 10 //cantidad de hilos por bloque
//
//declaracion del kernel, un kernel global deve ser void
//en esta ocacion voy a intentar optimizar el programa de practica
//voy a generar los datos del v1 en cpu y v2 en gpu
//asi solo sera necesario transferir v1 y N y regresar solamente vsum
__global__ void suma(int *v1, int *vsum, int N){
    //este sera un kernel multibloque
    /*
    para esto se necesita un identificador que distinga entre hilos
    de diferentes bloques para asignartares y supervisar faltantes o
    sobrantes
    */

    int ID = threadIdx.x + blockDim.x * blockIdx.x;

    //en caso de que me sobren hoilos uso un if
    if(ID < N){

        //aqui en lugar de usar un vector, creamos y usamos al vuelo
        int v2 = (N-1) - ID;
        
        //hacemos la suma con el valor recien generado
        vsum[ID] = v1[ID] + v2;
    }
}

//funcion principal
int main(){

    //declaracion de las variables necesarias
    //en esta ocacion solo use los vectores 1 en cpu y gpu y los vectores de suma

    int *hst_v1, *hst_vsum;
    int *dev_v1, *dev_vsum;

    //numero maximo de hilos
    int N = 25;
    int n = N * sizeof(int);

    //una vez declaradas las variables, las uso para reservar memoria

    //memoria en cpu

    hst_v1 = (int*)malloc(n);
    hst_vsum= (int*)malloc(n);

    //memoria en gpu

    cudaMalloc((void**)&dev_v1, n);
    cudaMalloc((void**)&dev_vsum, n);

    //inicializo el vector 1
    for(int i = 0; i < N; i++){
        hst_v1[i] = i;
    }

    //copia de datos al device
    cudaMemcpy(dev_v1, hst_v1, n, cudaMemcpyHostToDevice);

    //lanzamos el quernel con los hilos necesarios

    //calcular los hilos
    int block = N / hilos;

    //si el vector no es multiplo del bloque, lanzamos otro bloque
    //ahora van a sobrar hilos
    if(N%hilos != 0){
        block += 1;
    }

    //lanzamos el kernel con la cantidad de hilos necesaria
    suma<<<block, hilos>>>(dev_v1, dev_vsum, N);

    //una ve realizado el calculo, recojemos los datos
    cudaMemcpy(hst_vsum, dev_vsum, n, cudaMemcpyDeviceToHost);

    //mostrar los resultados
    for(int i = 0; i < N; i++){
        printf("[");
        printf("%2d", i + 1);
        printf("]");
        printf("%2d", hst_vsum[i]);
        printf("\n");
    }

    return 0;
}