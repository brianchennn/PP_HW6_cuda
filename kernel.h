#ifndef DERNEL_H_
#define KERNEL_H_

void hostFE_cuda(int filterWidth, float *filter, int imageHeight, int imageWidth,
        float *inputImage, float *outputImage);

#endif
