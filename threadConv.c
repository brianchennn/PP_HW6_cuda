#include "kernel_cu.h"

void convolution(int filterWidth, float *filter, int imageHeight, int imageWidth, float *inputImage,float *outputImage){

    hostFE(filterWidth, filter, imageHeight, imageWidth, inputImage,  outputImage);

}
