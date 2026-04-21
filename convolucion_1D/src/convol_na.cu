#include "../include/convol.cuh"

//este archivo esta destinado a definir la funcion donde toma los datos de memoria global

__global__ void conv_nat (float *arr1, float *arr2, const float ker[], int N, const int s){

    //identificador global
    int ID = threadIdx.x + blockDim.x * blockIdx.x;
    //radio 
    int radiusjeje = s/2;

    //solo entra N cantidad de hilos
    if (ID < N){

        //declaro el acumulador de suma de cada operacion
        float sum = 0.0f;

        //comienzo el bucle para iterar la cantidad de veces del tama;o del kernel, un bloque por hilo
        for(int k = 0; k < s; k++){

            //desde donde quiero empezar
            //hipotetico, hilo 0 iteracion 0
            //ID = 0, itracion 0 - 2, comienza en el dato -2, que no existe
            //para 100 datos
            //ID = 100, iteracion 4 r -2 termina en el dato 102, que no existe  
            int init = ID + (k - radiusjeje);
            if(init >= 0 && init < N){
                //desde el hilo 0 comienza saltandose 2 datos del kernel
                sum += arr1[init] * ker[k];
            }

        }
        //en cada hilo se suma en un bloque de memoria
        arr2[ID] = sum;
    }
}