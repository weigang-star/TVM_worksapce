#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <time.h>
#include "../nvml-power/nvmlPower.hpp"

#define M 1
#define N 49152
#define K 12288




dim3 dimGrid(16, 1, 1);
dim3 dimBlock(128, 1, 1);


extern "C" __global__ void __launch_bounds__(128) mymv_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN);



int main(){
    int repeat = 100;
    float warmupRatio = 0.1;
    float randMax = 1000.0;
    srand((unsigned)time(NULL));
    float *a, *b, *out;
    float *d_a, *d_b, *d_out; 

    // Allocate host memory
    a   = (float*)malloc(sizeof(float) * M * K);
    b   = (float*)malloc(sizeof(float) * K * N);
    out = (float*)malloc(sizeof(float) * M * N);

    // Initialize host arrays
    // memset(a,   1.0 * (rand() % 10000), sizeof(float) * M * K);
    for(int i = 0; i < M * K; i++) {
        a[i] = (float)(rand() / (float)RAND_MAX - 0.5) * 2.0 * randMax;
    }
    // memset(b,   1.0 * (rand() % 10000), sizeof(float) * K * N);
    for(int i = 0; i < N * K; i++) {
        b[i] = (float)(rand() / (float)RAND_MAX - 0.5) * 2.0 * randMax;
    }

    // Allocate device memory 
    cudaMalloc((void**)&d_a,   sizeof(float) * M * K);
    cudaMalloc((void**)&d_b,   sizeof(float) * K * N);
    cudaMalloc((void**)&d_out, sizeof(float) * M * N);

    // Transfer data from host to device memory
    cudaMemcpy(d_a, a, sizeof(float) * M * K, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float) * K * N, cudaMemcpyHostToDevice);

    // Executing kernel 
    for(int i = 0; i < repeat * warmupRatio; i++) {
        mymv_kernel0<<<dimGrid, dimBlock>>>(d_a, d_b, d_out);
    }
    cudaDeviceSynchronize();
    nvmlAPIRun();
    for(int i = 0; i < repeat; i++) {
        mymv_kernel0<<<dimGrid, dimBlock>>>(d_a, d_b, d_out);
    }
    cudaDeviceSynchronize();
    nvmlAPIEnd();
    
    // Transfer data back to host memory
    cudaMemcpy(out, d_out, sizeof(float) * M * N, cudaMemcpyDeviceToHost);

    // Deallocate device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);

    // Deallocate host memory
    free(a); 
    free(b); 
    free(out);
}
