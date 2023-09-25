
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
extern "C" __global__ void __launch_bounds__(128) mymatmul_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN) {
  float T_matmul_NN_local[16];
  __shared__ float data_shared[1024];
  __shared__ float kernel_shared[512];
  for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 2; ++j_c_outer_inner_init) {
    for (int j_c_inner_init = 0; j_c_inner_init < 4; ++j_c_inner_init) {
      T_matmul_NN_local[((j_c_outer_inner_init * 4) + j_c_inner_init)] = 0.000000e+00f;
      T_matmul_NN_local[(((j_c_outer_inner_init * 4) + j_c_inner_init) + 8)] = 0.000000e+00f;
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 64; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 8; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 128) + ((int)threadIdx.x))] = data[((((((((int)blockIdx.x) >> 7) * 65536) + (ax0_ax1_fused_outer_outer * 8192)) + ((((int)threadIdx.x) >> 4) * 1024)) + (k_outer_outer * 16)) + (((int)threadIdx.x) & 15))];
    }
    for (int ax0_ax1_fused_outer_outer_1 = 0; ax0_ax1_fused_outer_outer_1 < 4; ++ax0_ax1_fused_outer_outer_1) {
      kernel_shared[((ax0_ax1_fused_outer_outer_1 * 128) + ((int)threadIdx.x))] = kernel[(((((k_outer_outer * 65536) + (ax0_ax1_fused_outer_outer_1 * 16384)) + ((((int)threadIdx.x) >> 5) * 4096)) + ((((int)blockIdx.x) & 127) * 32)) + (((int)threadIdx.x) & 31))];
    }
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 2; ++k_outer_inner) {
      for (int j_c_outer_inner = 0; j_c_outer_inner < 2; ++j_c_outer_inner) {
        for (int k_inner = 0; k_inner < 8; ++k_inner) {
          for (int j_c_inner = 0; j_c_inner < 4; ++j_c_inner) {
            T_matmul_NN_local[((j_c_outer_inner * 4) + j_c_inner)] = (T_matmul_NN_local[((j_c_outer_inner * 4) + j_c_inner)] + (data_shared[((((((int)threadIdx.x) >> 2) * 16) + (k_outer_inner * 8)) + k_inner)] * kernel_shared[(((((k_outer_inner * 256) + (k_inner * 32)) + ((((int)threadIdx.x) & 3) * 8)) + (j_c_outer_inner * 4)) + j_c_inner)]));
            T_matmul_NN_local[(((j_c_outer_inner * 4) + j_c_inner) + 8)] = (T_matmul_NN_local[(((j_c_outer_inner * 4) + j_c_inner) + 8)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 16) + (k_outer_inner * 8)) + k_inner) + 512)] * kernel_shared[(((((k_outer_inner * 256) + (k_inner * 32)) + ((((int)threadIdx.x) & 3) * 8)) + (j_c_outer_inner * 4)) + j_c_inner)]));
          }
        }
      }
    }
  }
  for (int j_inner = 0; j_inner < 8; ++j_inner) {
    T_matmul_NN[((((((((int)blockIdx.x) >> 7) * 262144) + ((((int)threadIdx.x) >> 2) * 4096)) + ((((int)blockIdx.x) & 127) * 32)) + ((((int)threadIdx.x) & 3) * 8)) + j_inner)] = T_matmul_NN_local[j_inner];
    T_matmul_NN[(((((((((int)blockIdx.x) >> 7) * 262144) + ((((int)threadIdx.x) >> 2) * 4096)) + ((((int)blockIdx.x) & 127) * 32)) + ((((int)threadIdx.x) & 3) * 8)) + j_inner) + 131072)] = T_matmul_NN_local[(j_inner + 8)];
  }
}

