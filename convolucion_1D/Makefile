#makefile proyecto convolucion 1D CUDA

#variable almacenar compiladores
NVCC = nvcc	#cuda
GCC = g++	#c/c++

#variable que guarda las opciones de compilacion
#-I./include busca includes en la carpeta include
#-arch=sm_75 optimiza para mi arquitectura de gpu
COMMON_FLAGS = -I./include
CUDA_FLAGS = -arch=sm_75
CPP_FLAGS =   

NVCC_FLAGS = $(COMMON_FLAGS) $(CUDA_FLAGS)
GCC_FLAGS = $(COMMON_FLAGS) $(CPP_FLAGS)


#directorios de carpetas
SRC_DIR = src
BIN_DIR = bin
OUT_DIR = out
INC_DIR = include


#archivos

#buscar archivos .cu y .cpp por separado
SOURCES_CU = $(wildcard $(SRC_DIR)/*.cu)
SOURCES_CPP = $(wildcard $(SRC_DIR)/*.cpp)

#unir ambas listas en una sola
SOURCES = $(SOURCES_CU) $(SOURCES_CPP)

#crear objetos para .cu
OBJECTS_CU = $(SOURCES_CU:$(SRC_DIR)/%.cu=$(OUT_DIR)/%.o)

#crear objetos para .cpp
OBJECTS_CPP = $(SOURCES_CPP:$(SRC_DIR)/%.cpp=$(OUT_DIR)/%.o)

#unir todos los objetos
OBJECTS = $(OBJECTS_CU) $(OBJECTS_CPP)

#ejecutable final
TARGET = $(BIN_DIR)/programa

#crear las carpetas necesarias en caso de que se descargue el proyecto
$(shell mkdir -p $(BIN_DIR) $(OUT_DIR))


#****************************
#reglas principales

# Regla por defecto
all: $(TARGET)

# Crear el ejecutable enlazando los .o
$(TARGET): $(OBJECTS)
	$(NVCC) $^ -o $@
	@echo "compilación exitosa!"
	@echo "ejecutable: $(TARGET)"

# Compilar archivos .cu
$(OUT_DIR)/%.o: $(SRC_DIR)/%.cu
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@
	@echo "compilado CUDA: $(notdir $<)"

# Compilar archivos .cpp
$(OUT_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(GCC) $(GCC_FLAGS) -c $< -o $@
	@echo "compilado C++: $(notdir $<)"

#ejecutar el programa
run: all
	@echo "ejecutando--------"
	@cd $(BIN_DIR) && ./programa

execute:
	@if [ -f $(TARGET) ]; then \
		echo "ejecutando--------"; \
		cd $(BIN_DIR) && ./programa; \
	else \
		echo "error: ejecuta 'make' para compilar"; \
	fi

binclean:
	rm -f $(BIN_DIR)/*.bin
	@echo ".bin residuales eliminados"

#limpiar solo archivos objeto
clean:
	rm -f $(OUT_DIR)/*.o
	@echo ".o eliminados"

#limpiar todo (objetos y ejecutable)
distclean: clean
	rm -f $(TARGET)
	@echo "limpio"

#mostrar qué archivos se van a compilar
info:
	@echo "archivos fuente encontrados:"
	@echo "   CUDA: $(notdir $(SOURCES_CU))"
	@echo "   C++:  $(notdir $(SOURCES_CPP))"
	@echo ""
	@echo "objetos a generar:"
	@echo "   $(notdir $(OBJECTS))"
	@echo ""
	@echo "ejecutable: $(TARGET)"

#ayuda
help:
	@echo "comandos disponibles:"
	@echo "  make          	- compilar todo"
	@echo "  make run      	- compilar y ejecutar"
	@echo "  make clean    	- borrar archivos .o"
	@echo "  make distclean	- borrar .o y ejecutable"
	@echo "  make info     	- ver qué archivos se compilarán"
	@echo "  make execute  	- ejecutar el archivo ya compilado"
	@echo "  make binclean	- borra los archivos binarios de la carpeta bin"