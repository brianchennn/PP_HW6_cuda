#ifndef __HELPER_CU__
#define __HELPER_CU__

#include <stdio.h>
#include <stdlib.h>

// This function reads in a text file and stores it as a char pointer
char *readSource(char *kernelPath);

float *readFilter(const char *filename, int *filterWidth);
#endif
