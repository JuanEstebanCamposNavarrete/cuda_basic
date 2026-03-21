////////////////////////////////////////////////////////////////////////////////////////////////////
// programacion en cuda c/c++
// curso basico
// marzo 2026
////////////////////////////////////////////////////////////////////////////////////////////////////
// includes
#include<stdio.h>
#include<stdlib.h>
#include<cuda_runtime.h>
//defines
#define elementosx 10 //numero de columnas del eje x
#define elementosy 6  //numero de filas del eje y
//funcion kernel
__global__ void matriz(int *entrada, int *salida){
    //matriz bidfimencional x,y

    //eje x 
    int ejex = threadIdx.x;
    //eje y
    int ejey = threadIdx.y;

    //indice lineal usando las posiciones del eje x,y
    int globalx = ejex + ejey * elementosx;

    //indice global de la matriz desde eje y transpuesto
    int globaly = ejey + ejex * elementosy;

    //cambiamos los valores de la matriz en una transpuesta con los identificadores globales x y y
    salida[globaly] = entrada[globalx];
} 

//funcion main principal

int main(){

    //declaracion de variables puntero de tipo entero
    //variables host
    int *hst_m1, *hst_mtrans;

    //variables device
    int *dev_m1, *dev_mtrans;

    int memoria = elementosx * elementosy * sizeof(int);

    //aparto espacio en memoria
    //memoria del host
    hst_m1 = (int*)malloc(memoria);
    hst_mtrans = (int*)malloc(memoria);

    //memoria device
    cudaMalloc((void**)&dev_m1, memoria);
    cudaMalloc((void**)&dev_mtrans, memoria);

    //lleno la memoria del host
    for(int i = 0; i < elementosx * elementosy; i++){
        hst_m1[i] = i+1;
    }

    //copiar memoria del host al device
    cudaMemcpy(dev_m1, hst_m1, memoria, cudaMemcpyHostToDevice);

    //numero de elementos por fila y columna
    dim3 hilos(elementosx, elementosy);
    dim3 bloques(1, 1);

    //lanzamos el kernel para que haga los calculos
    matriz<<<bloques, hilos>>>(dev_m1, dev_mtrans);

    //copiamos la matriz transpuesta desde el device al host
    cudaMemcpy(hst_mtrans, dev_mtrans, memoria, cudaMemcpyDeviceToHost);


    //mostramos los resultados de la transposicion y del original
    //original
    printf("original \n");
    for(int i = 0; i < elementosy; i++){

        printf("[");

        for (int k = 0; k < elementosx; k++){
            printf("%2d", hst_m1[k + i * elementosx]);
            if(k != elementosx-1){
                printf(",");
            }
        }

        printf("] \n");
    }

    //transpuesta
    printf("\n\n\n transpuesta \n");
    for(int i = 0; i < elementosx; i++){

        printf("[");

        for (int k = 0; k < elementosy; k++){
            printf("%2d", hst_mtrans[k + i * elementosy]);
            if(k != elementosy-1){
                printf(",");
            }
        }

        printf("] \n");
    }

    free(hst_m1);
    free(hst_mtrans);
    cudaFree(dev_m1);
    cudaFree(dev_mtrans);

    return 0;
}