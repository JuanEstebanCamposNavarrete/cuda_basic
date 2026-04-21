#include "../include/convol.cuh"

__global__ void conv_shar (float *arr1, float *arr2, float const ker[], int N, int const radio){
    __shared__ float mem[260];

    //declaro identificadores global y por bloque
    int ID = threadIdx.x + blockDim.x * blockIdx.x;
    int id = threadIdx.x; 

    //carga de datos

    //defino en donde comienzan y terminan los bloques de memoria
    //bloque 0(blockid = 0 * blockdim = 255 == 0), bloque 1(blockid = 1 * blockdim = 256 == 256)(512, 768, 1024.....)
    int stack = blockIdx.x * blockDim.x;
    //indica en donde comienza cada bloque de datos para procesar
    //despues recorro en -r para poder capturar los datos mas adelante
    int glob = stack - radio;
    
    //en este bucle for, se reutilizan los hilos para cargar mas de un dato, pero solamente unos pocos
    //se hace una condicion en donde los hilos mas grandes no podran repetir el bucle, solo los primeros hilos
    for(int i = threadIdx.x; i < blockDim.x + radio * 2; i += blockDim.x){
        //el indice comienza con 0 y llega a 255, idhilo
        //despues digo, si es mas peque;o que la cantidad de hilos por bloque mas el radio *2, repite0
        //y ya que solo podrian repetir los primeros 4 hilos, esos 4 hilos cargan 2 datos en lugar de 1

        //aqui empieza la carga de los datos, primero le aplico in identificador a cada hilo para recorrerlo en el radio
        //basicamente incia en -2 y va a 257
        int ID_gl = glob + i;
        //este if, solo deja pasar a aquellos hilos que esten en el rango de 0 a 255
        //los primeros 4 hilos cambiaran su identificador de 0, 1, 2, 3 a 256, 257, 258, 259
        //en el if, solo entran los hilos con id entre 0 y 255, y en las siguientes iteraciones del bucle, se acomodan los hilos para entrar en la siguiente condicion
        if(ID_gl >= 0 && ID_gl < N){
            mem[i] = arr1[ID_gl];
        }else{
            mem[i] = 0.0f;
        }

    }
    __syncthreads();

    //empiezo a escribir el array de resultado
    if (ID < N) {
        //variable para almacenar el resultado
        float suma = 0.0f;
        //este bucle va desde -2 hasta 2(5 elementos)
        for (int k = -radio; k <= radio; k++) {
            //la variable va de 0 a 259
            int shared_idx = id + radio + k;
            //la variable suma acumula los resultados de 
            //las multimplicaciones de los valores de kernel y mem
            //en las posiciones correspondientes

            //el bucle se ejecuta 1 vez por hilo y se repite 5 veces
            suma += ker[k + radio] * mem[shared_idx];
        }
        //asigna el resultado en el bloque de memoria del array de resultado
        arr2[ID] = suma;
    }
}