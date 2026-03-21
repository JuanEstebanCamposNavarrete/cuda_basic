////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROGRAMACION EN CUDA C/C++
// CURSO BASICO
// MARZO 2026
////////////////////////////////////////////////////////////////////////////////////////////////////////
// includes
#include <stdio.h> // libreria estandar entrada y salida de datos
#include <stdlib.h> // libreria basica para gestion de memoria, conversiones entre datos, aleatoreidad.
#include <cuda_runtime.h> //agrega la api de cuda para acceder al gpu y agrega varias herramientas de la libreria para trabajar con funciones

////////////////////////////////////////////////////////////////////////////////////////////////////////
// defines
#define N 16 // para un array de 16 elementos

////////////////////////////////////////////////////////////////////////////////////////////////////////
//MAIN: rutina principal del programa

int main(){

    // declaraciones
    float *hst_A, *hst_B; //punteros para direccionar o seleccionar datos del host (CPU)
    float *dev_A, *dev_B; //punteros para direccionar o seleccionar datos del device (GPU)

    // reserva de datos en el host
    hst_A = (float*) malloc(N * sizeof(float)); //se usa malloc de la libreria estandar c++
    hst_B = (float*) malloc(N * sizeof(float)); //reserva N datos de tipo float en el host(CPU) vector B
    //malloc solo reserva bytes y no elementos, por eso se tiene que multiplicar el tipo de lato que quieres por el numero de bytes que quieres por elemento

    // reserva de datos en el device
    cudaMalloc((void**)&dev_A, N * sizeof(float));
    cudaMalloc((void**)&dev_B, N * sizeof(float));
 
    //inicializacion
    for(int i = 0; i < N; i++){
        hst_A[i] = (float)rand() / RAND_MAX;
        hst_B[i] = 0;
    }

    //movimiento de los datos
    cudaMemcpy(dev_A, hst_A, N * sizeof(float), cudaMemcpyHostToDevice);
        //de host al device
    cudaMemcpy(dev_B, dev_A, N * sizeof(float), cudaMemcpyDeviceToDevice);
        //de device a device
    cudaMemcpy(hst_B, dev_B, N * sizeof(float), cudaMemcpyDeviceToHost);
        //de device al host

    //muestra de resultados
    printf("entrada A");
    printf("\n");
    printf("[");
    for(int i = 0; i < N; i++){
        printf("%.2f", hst_A[i]);
        printf(",");
        printf("\n");
    }
    printf("]");

    printf("\n");

    printf("salida B");
    printf("\n");

    printf("[");
    for(int i = 0; i < N; i++){
        printf("%.2f", hst_B[i]);
        printf(",");
        printf("\n");
    }
    printf("]");

    printf("\n");

    //liberacion de recursos
    cudaFree(dev_A);
    cudaFree(dev_B);

    return 0;
}