default: conv

CC = gcc-10
CXX = g++
CXXFLAGS = -I./common -Iobjs/ -O3 -std=c++17 -Wall -g -fPIC -lm
NVCC = nvcc
FLAGS = -O3 -lOpenCL -m64 -ffloat-store -w -g -D CL_TARGET_OPENCL_VERSION=220

CUDA_LINK_FLAGS =  -rdc=true -gencode=arch=compute_61,code=sm_61 -Xcompiler '-fPIC' 
CUDA_COMPILE_FLAGS = --device-c  -gencode=arch=compute_61,code=sm_61 -Xcompiler '-fPIC' -g -O3
OBJS = main.o bmpfuncs.o hostFE.o serialConv.o helper.o
cu_OBJS = main2.o bmpfuncs.o serialConv.o kernel_cu.o helper_cu.o


conv: $(OBJS)
	$(CC) -o $@ $(OBJS) $(FLAGS)

cuda: $(cu_OBJS) 
	$(NVCC) ${CUDA_LINK_FLAGS} -o conv_cuda $(cu_OBJS)

kernel_cu.o: kernel_cu.cu kernel_cu.h
	${NVCC} ${CUDA_COMPILE_FLAGS} -c kernel_cu.cu -o $@

%.o: %cpp
	$(CXX) $< $(CXXFLAGS) -c -o $@

clean:
	rm -f conv_cuda conv *.o output.bmp ref.bmp
