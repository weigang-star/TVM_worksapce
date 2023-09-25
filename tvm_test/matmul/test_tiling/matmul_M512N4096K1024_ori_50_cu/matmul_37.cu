
#ifdef _WIN32
  using uint = unsigned int;
  using uchar = unsigned char;
  using ushort = unsigned short;
  using int64_t = long long;
  using uint64_t = unsigned long long;
#else
  #define uint unsigned int
  #define uchar unsigned char
  #define ushort unsigned short
  #define int64_t long long
  #define uint64_t unsigned long long
#endif
extern "C" __global__ void __launch_bounds__(64) mymatmul_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN) {
  float T_matmul_NN_local[32768];
  __shared__ float data_shared[1024];
  __shared__ float kernel_shared[8192];
  for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 32; ++j_c_outer_inner_init) {
    for (int i_c_inner_init = 0; i_c_inner_init < 64; ++i_c_inner_init) {
      for (int j_c_inner_init = 0; j_c_inner_init < 2; ++j_c_inner_init) {
        T_matmul_NN_local[(((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 4096)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 8192)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 12288)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 16384)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 20480)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 24576)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 64) + (j_c_outer_inner_init * 2)) + j_c_inner_init) + 28672)] = 0.000000e+00f;
      }
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 512; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 16; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 64) + ((int)threadIdx.x))] = data[((((ax0_ax1_fused_outer_outer * 32768) + ((((int)threadIdx.x) >> 1) * 1024)) + (k_outer_outer * 2)) + (((int)threadIdx.x) & 1))];
    }
    for (int ax0_ax1_fused_outer_outer_1 = 0; ax0_ax1_fused_outer_outer_1 < 128; ++ax0_ax1_fused_outer_outer_1) {
      kernel_shared[((ax0_ax1_fused_outer_outer_1 * 64) + ((int)threadIdx.x))] = kernel[(((k_outer_outer * 8192) + (ax0_ax1_fused_outer_outer_1 * 64)) + ((int)threadIdx.x))];
    }
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 2; ++k_outer_inner) {
      for (int j_c_outer_inner = 0; j_c_outer_inner < 32; ++j_c_outer_inner) {
        for (int i_c_inner = 0; i_c_inner < 64; ++i_c_inner) {
          for (int j_c_inner = 0; j_c_inner < 2; ++j_c_inner) {
            T_matmul_NN_local[(((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner)] = (T_matmul_NN_local[(((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner)] + (data_shared[((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner)] * kernel_shared[((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 4096)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 4096)] + (data_shared[((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner)] * kernel_shared[(((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner) + 2048)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 8192)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 8192)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 256)] * kernel_shared[((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 12288)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 12288)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 256)] * kernel_shared[(((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner) + 2048)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 16384)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 16384)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 512)] * kernel_shared[((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 20480)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 20480)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 512)] * kernel_shared[(((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner) + 2048)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 24576)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 24576)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 768)] * kernel_shared[((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner)]));
            T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 28672)] = (T_matmul_NN_local[((((i_c_inner * 64) + (j_c_outer_inner * 2)) + j_c_inner) + 28672)] + (data_shared[(((((((int)threadIdx.x) >> 5) * 128) + (i_c_inner * 2)) + k_outer_inner) + 768)] * kernel_shared[(((((k_outer_inner * 4096) + ((((int)threadIdx.x) & 31) * 64)) + (j_c_outer_inner * 2)) + j_c_inner) + 2048)]));
          }
        }
      }
    }
  }
  for (int i_inner = 0; i_inner < 64; ++i_inner) {
    for (int j_inner = 0; j_inner < 64; ++j_inner) {
      T_matmul_NN[(((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner)] = T_matmul_NN_local[((i_inner * 64) + j_inner)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 2048)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 4096)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 524288)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 8192)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 526336)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 12288)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 1048576)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 16384)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 1050624)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 20480)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 1572864)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 24576)];
      T_matmul_NN[((((((((int)threadIdx.x) >> 5) * 262144) + (i_inner * 4096)) + ((((int)threadIdx.x) & 31) * 64)) + j_inner) + 1574912)] = T_matmul_NN_local[(((i_inner * 64) + j_inner) + 28672)];
    }
  }
}

