//////////////////////////////////////////////////////////////////////////////////////////
// programacion en cuda c/c++
// Curso basico
// Marzo 2026
//////////////////////////////////////////////////////////////////////////////////////////
// includes
#include<stdlib.h>
#include<stdio.h>
#include<cuda_runtime.h>
//////////////////////////////////////////////////////////////////////////////////////////
//declaracion de funciones
//Global:funcion llamada desde el host y ejecutada en el device (kernel)
__global__ void suma(int *vector1, int *vector2, int *vec_suma, int n){

    //identificador del hilo, se usa threadidx por que es el identificados solo de hilos y se usa .x por que solo estoy trabajando en el eje x
    int miID = threadIdx.x;

    //inicializar el vector2
    vector2[miID] = (n-1) - miID;

    //escribir resultados
    vec_suma[miID] = vector1[miID] + vector2[miID];
}

int main(){
    //declarar los punteros
    int *hst_vec1, *hst_vec2, *hst_vecsum;
    int *dev_vec1, *dev_vec2, *dev_vecsum;

    //establecer el numero de elementos que quiero sumar, se puede hacer con un define o un static, incluso con pixeles de imagenes
    int N =8;

    //reservar espacios en memoria

    //reserva espacio en el host

    //llenas una variable puntero con un puntero del mismo tipo casteado a int, malloc recibe el mimero de bytes a apartar
    hst_vec1 = (int*)malloc(N * sizeof(int));
    hst_vec2 = (int*)malloc(N * sizeof(int));
    hst_vecsum = (int*)malloc(N * sizeof(int));

    //reserva espacio en el device

    //funcion, direccion de memoria en forma de puntero doble comun, numero de bytes
    cudaMalloc((void**)&dev_vec1, N * sizeof(int));
    cudaMalloc((void**)&dev_vec2, N * sizeof(int));   
    cudaMalloc((void**)&dev_vecsum, N * sizeof(int));

    //rellenar los vectores del host
    for(int i = 0; i < N; i ++){
        hst_vec1[i] = i;
        hst_vec2[i] = 0;
    }

    //copiar los datos desde el host hasta el device para hacer los calculos acelerados

    //direccion destino, direccion origen, numero de bytes, en que direccion se transfieren
    cudaMemcpy(dev_vec1, hst_vec1, N * sizeof(int), cudaMemcpyHostToDevice);

    //lanzar el kernel, es la funcion de suma que hizomos para ser lanzada desde el host en el device
    suma <<<1, N>>> (dev_vec1, dev_vec2, dev_vecsum, N);

    //recoger los datos del device
    cudaMemcpy(hst_vec2, dev_vec2, N * sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(hst_vecsum, dev_vecsum, N * sizeof(int), cudaMemcpyDeviceToHost);

    //impresion de resultados
    printf("vec1 \n");
    for(int i = 0; i < N; i++){
        printf("%2d", hst_vec1[i]);
    }
    printf("\n");

    printf("vec2 \n");
    for (int i = 0; i < N; i++){
        printf("%2d", hst_vec2[i]);
    }
    printf("\n");

    printf("vec sum \n");
    for (int i = 0; i < N; i++){
        printf("%2d", hst_vecsum[i]);
    }
    printf("\n");

    //libera menmoria
    cudaFree(dev_vec1);
    cudaFree(dev_vec2); 
    cudaFree(dev_vecsum);
    free(hst_vec1);
    free(hst_vec2);
    free(hst_vecsum);

    return 0;
}