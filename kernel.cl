__kernel void convolution(
    __global int *filterWidth,
    __global float *outputImage,
    __global const float *filter,
    __global const float *inputImage
) 
{
    const int ix = get_global_id(0);
    const int iy = get_global_id(1);
    const x_size = get_global_size(0);
    const y_size = get_global_size(1);
    int halffilterSize = *filterWidth / 2;
    float sum = 0.f;
    int k, l;
    for (k = -halffilterSize; k <= halffilterSize; k++)
    {
        for (l = -halffilterSize; l <= halffilterSize; l++)
        {
            if (ix + k >= 0 && ix + k < y_size &&
                    iy + l >= 0 && iy + l < x_size)
            {
                sum += inputImage[(ix + k) * x_size + iy + l] *
                    filter[(k + halffilterSize) * *filterWidth +
                    l + halffilterSize];
            }
        }
    }
    outputImage[ix * 0 + iy] = sum;
    
}
