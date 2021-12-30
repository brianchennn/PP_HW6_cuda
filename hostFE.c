#include <stdio.h>
#include <stdlib.h>
#include "hostFE.h"
#include "helper.h"

#define MAX_SOURCE_SIZE (0x100000)

void hostFE(int filterWidth, float *filter, int imageHeight, int imageWidth,
        float *inputImage, float *outputImage, cl_device_id *device,
        cl_context *context, cl_program *program)
{
    cl_int status;
    int filterSize = filterWidth * filterWidth;

    // Create a command queue
    cl_command_queue command_queue = clCreateCommandQueue(*context, *device, 0, &status);
    // Create memory buffers on the device for each vector
    cl_mem filter_width_mem = clCreateBuffer(*context, CL_MEM_READ_ONLY, 
                sizeof(int), NULL, &status);
    cl_mem filter_mem = clCreateBuffer(*context, CL_MEM_READ_ONLY, 
                filterSize * sizeof(float), NULL, &status);
    cl_mem inputImage_mem = clCreateBuffer(*context, CL_MEM_READ_ONLY, 
                imageHeight * imageWidth * sizeof(float), NULL, &status);
    cl_mem outputImage_mem = clCreateBuffer(*context, CL_MEM_WRITE_ONLY, 
                imageHeight * imageWidth * sizeof(float), NULL, &status);

    // Copy the filter and inputImage to their respective memory buffers
    
    status = clEnqueueWriteBuffer(command_queue, filter_width_mem, CL_FALSE, 0,
            sizeof(int), &filterWidth, 0, NULL, NULL);
    status = clEnqueueWriteBuffer(command_queue, filter_mem, CL_FALSE, 0,
            filterSize * sizeof(int), filter, 0, NULL, NULL);
    status = clEnqueueWriteBuffer(command_queue, inputImage_mem, CL_FALSE, 0, 
            imageHeight * imageWidth * sizeof(int), inputImage, 0, NULL, NULL);

    // Create the OpenCL kernel
    cl_kernel kernel = clCreateKernel(*program, "convolution", &status);
    
    // Set the arguments of the kernel
    status = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&filter_width_mem);
    status = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&outputImage_mem);
    status = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *)&filter_mem);
    status = clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *)&inputImage_mem);
    
    // Execute the OpenCL kernel on the list
    size_t localws[2] = {40,20};
    size_t globalws[2] = {imageWidth, imageHeight};
    //size_t global_item_size = imageHeight * imageWidth; // Process the entire lists
    //size_t local_item_size = 64; // Divide work items into groups of 64
    status = clEnqueueNDRangeKernel(command_queue, kernel, 2, NULL, 
            globalws, localws, 0, NULL, NULL);
    // Read the memory buffer C on the device to the local variable C
    status = clEnqueueReadBuffer(command_queue, outputImage_mem, CL_TRUE, 0,
            imageHeight * imageWidth * sizeof(float) , outputImage, 0, NULL, NULL);

    
    status = clFlush(command_queue);
    status = clFinish(command_queue);
    status = clReleaseKernel(kernel);
    status = clReleaseProgram(program);
    status = clReleaseMemObject(inputImage_mem);
    status = clReleaseMemObject(outputImage_mem);
    status = clReleaseMemObject(filter_width_mem);
    status = clReleaseMemObject(filter_mem);
    status = clReleaseCommandQueue(command_queue);
    status = clReleaseContext(*context);
    //free(inputImage);
    //free(outputImage);
    //free(filter);
    return 0;

}
