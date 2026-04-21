////////////////////////////////////////////////////////////////////////////////////////////////////
/*
Especificaciones
Kernel de convolución 1D: [1, 2, 3, 2, 1] (normalizado, suma = 9)
Requerimientos:
Longitud del kernel: 5 taps:
Radio: 2 elementos
Tamaño del array de entrada: N = 1,048,576 elementos (2^20)
Tipo de dato: float
Entrada esperada:
Archivo binario data/input_signal_1d.bin
Rango de valores: [-1.0, 1.0] distribuidos uniformemente
Generado con script provisto (no lo implementas tú)
Salida esperada:
Archivo output_1d_naive.bin (desde convolution_1d_naive)
Archivo output_1d_shared.bin (desde convolution_1d_shared)
Ambos archivos deben ser bitwise identical
Restricciones técnicas:
Implementación	Requisitos
Naive	Cada hilo lee desde memoria global sin usar shared memory
Shared	Cada bloque carga en shared memory: block_size + 2*radius elementos. Usar padding explícito para bordes (valor 0 fuera del rango)
Condiciones de borde: Zero padding (fuera del array = 0.0)
Parámetros de lanzamiento:
Block size: 256 hilos
Grid size: ceil(N / block_size)
Shared memory por bloque: (256 + 4) * sizeof(float) bytes
Validación: Error relativo máximo permitido: 1e-6 respecto a versión CPU de referencia
*/
////////////////////////////////////////////////////////////////////////////////////////////////////
// Programacion en C/C++ CUDA
// Abril 2026
// Juan Esteban Campos Navarrete
// Convolucion 1D
////////////////////////////////////////////////////////////////////////////////////////////////////
//includes
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#include "../include/convol.cuh"

//funcion principal main
int main(){
    //declaro las variables a utilizar
    //funciones del host
    float *hst_arr1 = NULL, *hst_arr2 = NULL;
    //variuables de retorno de kernel
    float *hst_sh_arr2 = NULL, *hst_nat_arr2 = NULL;
    //funciones shared kernel
    float *dev_sh_arr1 = NULL, *dev_sh_arr2 = NULL;
    //funciones native kernel
    float *dev_nat_arr1 = NULL, *dev_nat_arr2 = NULL;

    //calculo la cantidad de datos en bytes
    FILE *arc = fopen("../data/datos.bin", "rb");
    if(!arc){
        printf("error abrir archivo data\n");
        return 1;
    }

    //calcular el tama;o del archibo
    fseek(arc, 0, SEEK_END);
    long bytes = ftell(arc);
    fseek(arc, 0, SEEK_SET);

    //cantidad de datos 
    int N = bytes/4;


    //inicio los arrays y hago las comprobaciones de errores
    hst_arr1 = (float*)malloc(bytes);
    hst_arr2 = (float*)malloc(bytes);

    //salida datos funciones device a host
    hst_nat_arr2 = (float*)malloc(bytes);
    hst_sh_arr2 = (float*)malloc(bytes);

    if(!hst_arr1 || !hst_arr2 || ! hst_nat_arr2 || !hst_sh_arr2){
        printf("error en malloc");
        return 1;
    }

    //llenar la memoria del host con el archivo
    size_t tam = fread(hst_arr1, sizeof(float), bytes/sizeof(float), arc);
    if(tam != bytes/sizeof(float)){
        printf("error al leer el archivo: %zu/%ld floats no leidos\n", tam, bytes/sizeof(float));
        free(hst_arr1);
        free(hst_arr2);
        //cierro el archivo binario
        fclose(arc);
        return 1;
    }
     
    fclose(arc);

    //declaro cuantos bloques voy a necesitar
    int bloques = (N + blocks - 1)/blocks;

    //numero de elementos por fila y columna
    dim3 hilos(blocks);
    dim3 bloque(bloques);

    //llamo a las funciones que ejecutan el programa en cada caso y creo nuevossarchivos con los resultados

    //primero ejecuto en el host
    conv_host (hst_arr1, hst_arr2, kernel, N, size);

    /*****************************************************************************************************/

    //aparto la memoria en native
    cudaError err = cudaMalloc((void**)&dev_nat_arr1, bytes);
    if(err != cudaSuccess){
        printf("error cudamalloc 1: %s \n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void**)&dev_nat_arr2, bytes);
    if(err != cudaSuccess){
        printf("error en cuda malloc 2: %s \n", cudaGetErrorString(err));
        return 1;
    }

    //copio el array a device native array 1
    cudaMemcpy(dev_nat_arr1, hst_arr1, bytes, cudaMemcpyHostToDevice);

    //llamo la funcion native
    conv_nat <<<bloque, hilos>>>(dev_nat_arr1, dev_nat_arr2, kernel, N, size);

    //coipio los resultados de device native array 2 
    cudaMemcpy(hst_nat_arr2, dev_nat_arr2, bytes, cudaMemcpyDeviceToHost);

    /*****************************************************************************************************/
    //aparto memoria en shared
    err = cudaMalloc((void**)&dev_sh_arr1, bytes);
    if(err != cudaSuccess){
        printf("error cudamalloc 3: %s \n", cudaGetErrorString(err));
        return 1;
    }

    err = cudaMalloc((void**)&dev_sh_arr2, bytes);
    if(err != cudaSuccess){
        printf("error en cudamalloc 4: %s \n", cudaGetErrorString(err));
        return 1;
    }

    //copio la memoria a device shared array 1
    cudaMemcpy(dev_sh_arr1, hst_arr1, bytes, cudaMemcpyHostToDevice);

    //llamo a la funcion shared
    conv_shar <<<bloque, hilos>>>(dev_sh_arr1, dev_sh_arr2, kernel, N, radio);

    //Copio los resultados de device shared array 2
    cudaMemcpy(hst_sh_arr2, dev_sh_arr2, bytes, cudaMemcpyDeviceToHost);

    /*****************************************************************************************************/

    //nombres para los 3 archivos
    char n1[] = "res_arc_hst.bin", n2[] = "res_arc_dev_nat.bin", n3[] = "res_arc_dev_sh.bin";

    //CREO LOS 3 ARCHIVOS DE RESULTADOS
    binario(hst_arr2, N, n1);
    binario(hst_nat_arr2, N, n2);
    binario(hst_sh_arr2, N, n3);

    for(int i = 0; i < 100; i++){
        printf("1 host: %.5f, 2 native: %.5f, 3 shared: %.5f \n", hst_arr2[i], hst_nat_arr2[i], hst_sh_arr2[i]);
    }

    //libero la memoria usada

    free(hst_arr1);
    free(hst_arr2);
    free(hst_sh_arr2);
    free(hst_nat_arr2);
    cudaFree(dev_sh_arr1);
    cudaFree(dev_sh_arr2);
    cudaFree(dev_nat_arr1);
    cudaFree(dev_nat_arr2);

    //ahora comparo los archivosaaaaa, hice mi funcion para que compare arrays en lugar de archivos
    //tengo que cambiarla
    differ(n1, n2);
    differ(n1, n3);
    differ(n2, n3);

    return 0;
}