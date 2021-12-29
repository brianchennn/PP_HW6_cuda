#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include "kernel.h"

__global__ void convolution(
    int *filterWidth,
    float *outputImage,
    const float *filter,
    const float *inputImage
) 
{
    const int ix = blockIdx.x * blockDim.x + threadIdx.x;
    const int iy = blockIdx.y * blockDim.y + threadIdx.y;
    const int x_size = gridDim.x;
    const int y_size = gridDim.y;
    int halffilterSize = *filterWidth / 2;
    float sum = 0.0;
    int k, l;
    for (k = -halffilterSize; k <= halffilterSize; k++)
    {
        for (l = -halffilterSize; l <= halffilterSize; l++)
        {
            if (iy + k >= 0 && iy + k < y_size &&
                    ix + l >= 0 && ix + l < x_size)
            {
                sum += inputImage[(iy + k) * x_size + ix + l] *
                    filter[(k + halffilterSize) * *filterWidth +
                    l + halffilterSize];
            }
        }
    }
    outputImage[iy * x_size + ix] = sum;    
}

void hostFE(int filterWidth, float *filter, int imageHeight, int imageWidth,
        float *inputImage, float *outputImage)
{
    int filterSize = filterWidth * filterWidth;

    // Create memory buffers on the device for each vector
    int *dev_filter_width;
    float *dev_filter, *dev_inputImage, *dev_outputImage;
    cudaMalloc(&dev_filter_width, sizeof(int));
    cudaMalloc(&dev_filter, filterSize * sizeof(float));
    cudaMalloc(&dev_inputImage, imageHeight * imageWidth * sizeof(float));
    cudaMalloc(&dev_outputImage, imageHeight * imageWidth * sizeof(float));
    
    // Copy the filter and inputImage to their respective memory buffers
    cudaMemcpy(dev_filter_width, &filterWidth, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_filter, filter, filterSize * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_inputImage, inputImage, imageHeight * imageWidth * sizeof(float), cudaMemcpyHostToDevice);

   
    // Execute the OpenCL kernel on the list
    dim3 threadPerBlock(10,10);
    dim3 numBlocks(imageWidth / threadPerBlock.x, imageHeight / threadPerBlock.y);
    convolution<<<numBlocks, threadPerBlock>>>(dev_filter_width, dev_outputImage, dev_filter, dev_inputImage);
    cudaMemcpy(outputImage, dev_outputImage, imageHeight * imageWidth * sizeof(float), cudaMemcpyDeviceToHost);
    cudaFree(dev_filter_width);
    cudaFree(dev_filter);
    cudaFree(dev_inputImage);
    cudaFree(dev_outputImage);
}
