#ifndef CONVOL_CUH
#define CONVOL_CUH
#ifdef __CUDACC__
    //compilador nvcc (CUDA)
    #define CUDA_HOST __host__
    #define CUDA_DEVICE __device__
    #define CUDA_GLOBAL __global__
    #define CUDA_SHARED __shared__
#else
    // compilador g++ (C++ puro)
    #define CUDA_HOST
    #define CUDA_DEVICE
    #define CUDA_GLOBAL
    #define CUDA_SHARED
#endif

//constantes para kernel

const int size = 5;             //tama;o del kernel
const int blocks = 256;         //hilos por bloque
const int radio = 2;            //radio del kernel 
const float kernel[5] = {1.0f, 2.0f, 3.0f, 2.0f, 1.0f};  //el kernel que voy a aplicar a mis datos

//funciones CPU para referencia, hace la misma operacion en la CPU
CUDA_HOST void conv_host (float *arr1, float *arr2, const float ker[], const int N, const int s);

//funcion para medir diferencias entre dos resultados en forma de array

CUDA_HOST void differ(char *pasa_el_name, char *pasa_el_name_x2);

//funcion para crear archivos binarios con los resultados de las operaciones

CUDA_HOST void binario(float *arr, int N, char *name);

//shared el kernel que se encarga de cargar los datos desde memoria compartida

CUDA_GLOBAL void conv_shar (float *arr1, float *arr2, const float ker[], int N, int const radio);

//native el kernel que carga los datos desde la memoria global

CUDA_GLOBAL void conv_nat (float *arr1, float *arr2, const float ker[], int N, int const s);

#endif