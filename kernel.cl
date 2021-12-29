__kernel void convolution(
    __global int *filterWidth,
    __global float *outputImage,
    __global const float *filter,
    __global const float *inputImage
) 
{
    const int ix = get_global_id(0);
    const int iy = get_global_id(1);
    const int x_size = get_global_size(0);
    const int y_size = get_global_size(1);
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
