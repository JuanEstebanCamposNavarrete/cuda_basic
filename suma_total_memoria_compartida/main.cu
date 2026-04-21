/*
dado un array de numeros enteros en el host,
calcular la suma total de todos sus elementos
utilizando memoria compartida en cuda

Array de 1024 elementos: [1, 2, 3, ..., 1024]
Suma total (CPU): 524800
Suma total (GPU): 524800
Verificacion: CORRECTA
Tiempo CPU: X.XX ms
Tiempo GPU: Y.YY ms
Speedup: Z.ZZx

*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// Programacion en C/C++ CUDA
// Juan Esteban Campos Navarrete
// Marzo 2026
////////////////////////////////////////////////////////////////////////////////////////////////////
//includes
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

//constantes
const int blocks = 256;
const int elementos = 2048;
//kernel
__global__ void suma_mem(int *ar, int *s, int N){
    //esta funcion usa memoria compartida y rediccion paralele o binaria
    //primero declaro el identificador global de cada hilo y el didentificador por cada bloque
    int id = threadIdx.x;
    int ID = threadIdx.x + blockIdx.x * blockDim.x;

    //declaro la memoria compatrida
    __shared__ int mem[256];
    //de antemano se establece que los bloques contienen 256 hilos, potencia de dos, este algoritmo funciona solo en 1 dimencion sin modificaciones

    //a esto se le llama padding con ceros, en caso de que N sea menor que la cantidad de hilos, se escribe 0 en memoria
    if(ID < N){
        //se usa para no sobreescribir la memoria y evitar conflictos
        mem[id] = ar[ID];
    }else{
        //la memoria se rellena con basura para evitar que accedan y hagan conflictos de bancos
        mem[id] = 0;
    }

    //uso syncthreads para que los hilos esperen a que los datos esten completos y lean informacion correcta
    __syncthreads();

    //realizo la suma  
    //aqui hay varios metodos que se pueden usar, pero voy a usar uno clasico de reduccion paralela simple
    //reduccion padding
    for(int i = 1; i < blockDim.x; i *= 2){
    //este algoritmo va duplicando la distancia entre los bloques de memoria, es un arbol binario
    int idx = id + i;
    //esta ultima linea es un protector, para que nunca ocurra un desbrodamiento
        if(id % (2*i) == 0 && idx < blockDim.x){
            //el espacio entre bloques empieza por 1, 2, 4, 8, 16, 32... y si el identificador del hilo rebasa la memoria no puede ejecutar esto
            mem[id] += mem[id + i];
            //esta suma quiere decir que en el espacio de memoria compartida que especifica en el if, se suma la memoria de ese mismo bloque, mas el contenido del bloque que esta recorrido a la derecha 2*i veces
        }
        //despues de realizar la primera iteracion de sumas, bloqueo para esperar todos los procesos
        __syncthreads();
    }

    //hago que cada bloque sume sus resultados, diciendo que todos los hilos con identificador 0 realicen una suma atommica
    //uso atomicadd para evitar que varios hilos escriban en memoria
    if(id == 0){
    //si el id del hilo de cada bloque es o (4 hilos) entra aqui
        atomicAdd(s, mem[0]);
        //cada bloque tiene su propia memoria compartida con mem[0], llamo los 4 hilos para sumar 4 espacios de memoria en la memoria del puntero s
        //este algoritmo funciona para casi todas las operaciones excepto resta y divicion
    }
    /*
    atomicAdd()    Existe suma
    atomicSub()    Existe resta
    atomicMin()    Existe minimo
    atomicMax()    Existe maximo
    atomicAnd()    Existe compuerta and
    atomicOr()     Existe compuerta or
    atomicXor()    Existe compuerta xor
    atomicExch()   Existe intercambio
    atomicMul()    NO existe multiplicacion
    atomicDiv()    NO existe divicion
    atomicPow()    NO existe potencia
    */
}

//funcion para imprimir el array
void print(int ar[], int tam){
    printf("{");
    for(int i = 0; i < tam; i++){
        printf("%d", (int)ar[i]);
        if(i<tam-1){
            printf(",");
        }
    }
    printf("}\n");

}

//funcion para sumar en el host
void suma(int ar[], int *s, int N){
   //esta funcion suma de manera secuencial el array
   for(int i = 0; i < N; i++){
    *s = *s + ar[i];
   }
}

//funcion main principal
int main(){

    //declaro la cantidad de bytes necesarios para apartar en memoria
    int bytes = elementos * 4;

    //declaro cuantos bloques voy a necesitar
    int bloques = (elementos + blocks - 1)/blocks;

    //declaro las variables que voy a usar para inglesar los datos en memoria del host y el device
    int *hst_arr, *hst_sd = NULL, *hst_sh = NULL;
    int *dev_arr, *dev_s = NULL;

    //inicio el array del host
    hst_arr = (int*)malloc(bytes);
    //son los punteros que van a guardar los resultados de las sumas de host y device
    hst_sd = (int*)malloc(4);
    hst_sh = (int*)malloc(4);
    if(!hst_arr || !hst_sd || !hst_sh){
        printf("error en malloc");
        return 0;
    }

    //lleno el array
    for(int i = 0; i < elementos; i++){
        hst_arr[i] = i+1;
    }

    //mido el tiempo 
    clock_t t1 = clock();
    //primero hago la suma en el host
    suma(hst_arr, hst_sh, elementos);
    //termina de medir el tiempo
    clock_t t2 = clock();
    //calculo el tiempo
    double tiempo_host = (double)(t2 - t1)/CLOCKS_PER_SEC;

    //una vez iniciado el array, aparto memoria en el device
    cudaError err = cudaMalloc((void**)&dev_arr,(bytes));
    if(err != cudaSuccess){
        printf("error en cudamalloc %s", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    cudaError err1 = cudaMalloc((void**)&dev_s, (4));
    if(err1 != cudaSuccess){
        printf("error en cudamalloc %s", cudaGetErrorString(err1));
    }

    //una vez apartada e iniciada la memoria, transfiero los datos del host al device

    cudaMemcpy(dev_arr, hst_arr, bytes, cudaMemcpyHostToDevice);

    //declaro las variables de tiempo que voy a usar para medir la suma en el device
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    //EMPIEZO A MEDIR EL TIEMPO
    cudaEventRecord(start);

    //lanzo el kernel
    suma_mem<<<bloques, blocks>>>(dev_arr, dev_s, elementos);

    //termino de medir el tiempo despues de que termina el proceso de cuda
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    //calculo el tiempo
    float t;
    cudaEventElapsedTime(&t, start, stop);

    //traigo los resultados de la suma para verificar que no haya errores
    cudaMemcpy(hst_sd, dev_s, 4, cudaMemcpyDeviceToHost);

    //imprimo el array original
    print(hst_arr, elementos);

    //imprimo el resultado de la suma del host con su tiempo
    printf("\n\n host: %d, %.5f \n\n", *hst_sh, tiempo_host);

    //imprimo el resiltado de la suma del device con su tiempo
    printf("\n\n device: %d, %.5f \n\n", *hst_sd, t);
    
    //al final libero toda la memoria
    free(hst_arr);
    free(hst_sd);
    free(hst_sh);
    cudaFree(dev_arr);
    cudaFree(dev_s);

    return 0;
}
//usar la libreria estandar de c time no es muy preciso al parecer