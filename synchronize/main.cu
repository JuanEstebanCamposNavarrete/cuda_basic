//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// programacion en cuda C/C++
// curso basico
// marzo 2026
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// includes
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
//constantes
//usare esta cantidad de hilo por la ocupacion
const int threadsperblock = 256;
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

    //pruebo con un array de enteros de diferentes valores para verificar los tiempos de ejecucion en cada caso
    int val[] = {
        //todos los valores manejados aqui dentro seran de tiempo int, las operaciones se manejaran en 4 bytes 
        1 << 5, // esto es 2 elevado a la 5 = 32 elementos enteros, 32 * 4 bytes es 128 bytes, y 128 * 8 son 1024 bits
        1 << 8, // 256 elementos
        1 << 10, // 1,024 elementos
        1 << 12,  // 4,096 elementos
        1 << 14,  // 16,384 elementos
        1 << 16,  // 65,536 elementos
        1 << 18,  // 262,144 elementos
        1 << 20,  // 1,048,576 elementos
        1 << 22,  // 4,194,304 elementos
        1 << 24   // 16,777,216 elementos

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
        //declaro las variables que voy a usar al lanzar el kernel
        int hilos, bloques;
        //antes de ocupar los recursos del sistema, debo calcular la ocupacion optima de hilos y bloques segun N datos       

        //aqui declaro los punteros y la cantidad de datos de cada vector
        int *hst_vec1 = NULL, *hst_vecsum = NULL;
        int *dev_vec1 = NULL, *dev_vecsum = NULL;
        
        //variable que contiene los datos iterados del array
        int N = val[i];
        //en este caso al usar valores grandes, tengo que usar el tipo de dato size_t, que representa tama;os en forma de bytes, para no tener problemas
        size_t bytes = N * sizeof(int);
        //guarda el tama;o en la variable, del valor iterado multiplicado por el tipo de datos que es (int 4 bytes * millones de elementos)

        //una vez establecido el tama;o que necesito, y declaradas las variables, puedo apartar el espacio en memoria necesario
        //memoria en el host

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
        cudaError err1 = cudaMalloc((void**)&dev_vecsum, bytes);
        if(err != cudaSuccess){
            printf("error a la hora de apartar memoria en cuda %s", cudaGetErrorName(err1));
            exit(EXIT_FAILURE);
        } 
        //los errores a la hora de apartar memoria normalmente ocurren cuando la memoria esta completamente llena, lo mejor es terminar el proceso

        //despues de las partes en donde pueden haber errores, puedo calcular hilos y bloques
        hilos = threadsperblock;
        bloques = (N + hilos - 1)/hilos;
        //esta formula redondea el numero de recursos por arriba, puede que sobren pero es aceptable en cuda al precer
        //aun falta buscar el tipo de resolucion que tendran otros tipos de problemas

        //una vez apartada la memoria, puedo inicializarla
        for(int i = 0; i < N; i++){
            //el puntero con N datos se inicializa en cada posicion
            hst_vec1[i] = i + 1;
        }
        //esto podria ser un problema, ya que la gpu esta esperando a que la cpu inicialize los datos, mas adelante inicializre la cpu antes de apartar espacio en gpu
        
        //una vez inicializada tengo que transferir los datos a la gpu, al mismo tiempo comienzo a medir el tiempo
        cudaEventRecord(start);
        cudaMemcpy(dev_vec1, hst_vec1, N * sizeof(int), cudaMemcpyHostToDevice);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        //las variables guardan el flag de cada momento para medir la diferencia y saber el tiempo
        float t1 = 0, t2 = 0, t3 = 0; // variable que guarda el primer tiempo medido
        cudaEventElapsedTime(&t1, start, stop);
        
        //lanzo y mido los tiempos de ejecucion del kernel
        cudaEventRecord(start);
        suma<<<bloques, hilos>>>(dev_vec1, dev_vecsum, N);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&t2, start, stop);

        //copio la memoria de vuelta y mido los tiempos
        //en cudamemcopy implicitamente tiene una sincronizacion, espera a que todos los procesos esten listos

        //copio los datos de vuelta
        cudaEventRecord(start);
        cudaMemcpy(hst_vecsum, dev_vecsum, N * sizeof(int), cudaMemcpyDeviceToHost);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&t3, start, stop);

        //comienza la muestra de resultados

        //imprimo la cantidad de datos
        //es mi primer programa de este tipo, para visualizarlo imprimo la informacion que me ayuda a entenderlo
        printf("\n");
        printf("son %d elementos y el tama;o en megabytes es %.5f mb", N, (double)bytes / (1024 * 1024));
        printf("\n");        cudaEventSynchronize(stop);

        //divido la cantidad total de bytes entre la cantidad de bytes que hay en un megabyte (x/(1024*1024))
        //imprimo la cantidad de recursos usados
        printf("\nHilos por bloque = %d", hilos);
        printf("\nBloques = %d", bloques);
        //imprtmo los tiempos
        printf("\nTiempo H2T = %.5f ms", t1);
        printf("\nTiempo P = %.5f ms", t2);
        printf("\nTiempo D2H = %.5f", t3);
        printf("\nTiempo total = %.5f ms", t1 + t2 + t3);
        printf("\n");
        //al ser una gran cantidad de datos, no los voy a imprimir

        free(hst_vec1);
        free(hst_vecsum);
        cudaFree(dev_vec1);
        cudaFree(dev_vecsum);
    }  
    return 0;
}