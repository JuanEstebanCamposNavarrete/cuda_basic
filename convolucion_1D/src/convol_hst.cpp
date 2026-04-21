#include "../include/convol.cuh"
#include <math.h>
#include <stdio.h>

using namespace std;

//plantilla de entrada
//char *plan_ent = "../data/%s.bin";
char plan_sal[] = "../out/%s.txt";

char plan_in[] = "../bin/%s";

//declaro un espacio temporal para usarlo en el for
char ruta[512] = {0};
char nombre_resultado[512] = {0};


//este archivo esta destinado a definir las funciones que se ejecutaran en la CPU de cualquier tipo

//funcion para medir diferencias entre los resultados
void differ(char *pasa_el_name, char *pasa_el_name_x2){
    ruta[512] = {0};
    //declaro el contador de errores
    int arr[100] = {0};
    //declaro array de 2 nombres para guardar ambos archivos
    char *archivos[2] = {pasa_el_name, pasa_el_name_x2};
    //declaro un array vacio que guarda los dos archivos
    FILE *docs[2] = {NULL, NULL};
    //declaro otro array para guardar los tama;os
    long bytes[2] = {0, 0};
    //almacen diferencia absoluta
    float dif = 0.0f;

    //buvle que solo se ejecuta dos veces
    //este bucle abre ambos archivos, almacena cada archivo en su espacio de array y guarda los tama;os 
    for(int i = 0; i < 2; i++){
        //uso sprintf para crear la ruta completa de cada archivo
        sprintf(ruta, plan_in, archivos[i]);
        //printf("%s \n", archivos[i]);

        //en cada vuelta, la variable ruta se reinicia
        docs[i] = fopen(ruta, "rb");
        //abro los documentos y los fuardo en el array
        if(!docs[i]){
            //manejo de errores
            printf("error abrir archivo func differ \nw");
            exit(EXIT_FAILURE);
        }

        //GUARDO EL TAMA;P O DE LOS ARCHIVOS
        fseek(docs[i], 0, SEEK_END);
        bytes[i] = ftell(docs[i]);
        fseek(docs[i], 0, SEEK_SET);

    }
    //printf("b1: %li \n", bytes[0]);
    //printf("b2: %li \n", bytes[1]);

    //esto verifica que el tama;o de los archivos sea como minimo el mismo
    if(bytes[0] != bytes[1]){
        printf("\n archivos de tama;os diferentes: \n");
        printf("arch %s : tam : %lu bytes\n", archivos[0], bytes[0]);
        printf("arch %s : tam : %lu bytes\n", archivos[1], bytes[1]);
        exit(EXIT_FAILURE);
    }

    //DEBO ALMACENAR LA INFORMACION DE LOS ARCHIVOS EN DOS ARRAYS
    float *arch1 = NULL, *arch2 = NULL;

    arch1 = (float*)malloc(bytes[0]);
    arch2 = (float*)malloc(bytes[1]);

    if(!arch1 || !arch2){
        printf("error malloc archivos func differ \n");
        exit(EXIT_FAILURE);
    }

    //cargo los datos de los archivos
    fread(arch1, 1, bytes[0], docs[0]);
    fread(arch2, 1, bytes[1], docs[1]);

    //cantidad de datos 
    int N = bytes[0]/4;

    for(int i = 0; i < N; i++){

        //calculo la diferencia absoluta
        //el resultado siempre es [i]);
        dif = fabs(arch1[i] - arch2[i]);

        //escalo el resultado con escala logaritmica y lo trunco en maximo 99
        //esto se guarda en el array de errores, donde mientras mayor sea el error
        //en el array se guarda en la escala de 0 a 99, sumando 1 en cada caso
        int esc = (dif * 1e6) < 100 ? (int)(dif * 1e6) : 99;
        //aqui trunco el resultado a 99 o menos
        arr[esc] ++;
    }

    printf("comp: \n");
    for(int i = 0; i < 100; i++){
        printf("%d: %s---%s %d \n", i, pasa_el_name, pasa_el_name_x2, arr[i]);
    }
    printf("\n\n\n");


    //libero la memoria usada
    free(arch1);
    free(arch2);

    //una vez tengo los datos en el array de diferencias, puedo almacenarlo o imprimirlo

    //reinicio el valor de la ruta
    ruta[512] = {0};

    //uso sprintf para crear la ruta completa de cada archivo
    sprintf(nombre_resultado, "resultado_%s_%s", pasa_el_name, pasa_el_name_x2);

    sprintf(ruta, plan_sal, nombre_resultado);

    FILE *arch;
    arch = fopen(ruta, "wb");
    if(arch == NULL){
        exit(1);
    }

    fwrite(arr, sizeof(int), 100, arch);
    //cierro los archivos que he abierto
    fclose(docs[0]);
    fclose(docs[1]);
    fclose(arch);
}

//funcion de convolicion ejecutado en host
void conv_host (float *arr1, float *arr2, const float ker[], int N, int s){

    int r = s/2;
    for(int i = 0; i < N; i++){

        float suma = 0.0f;
        int val = 0;

        for(int k = 0; k < s; k ++){
            int id = i - r + k;
            if(id >= 0 && id < N){
                suma += arr1[id] * ker[k];
                val = val + 1;
            }
        }
        arr2[i] = suma;
    }
}

//funcion para crear archivos binarios con los resultados de las operaciones
void binario(float *arr, int N, char *name){
    ruta[512] = {0};

    //uso sprintf para crear la ruta completa de cada archivo
    sprintf(ruta, plan_sal, name);

    FILE *arch;
    arch = fopen(name, "wb");
    if(arch == NULL){
        exit(1);
    }

    fwrite(arr, sizeof(float), N, arch);
    fclose(arch);
}