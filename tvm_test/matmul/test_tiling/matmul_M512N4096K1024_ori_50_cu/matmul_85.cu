
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
extern "C" __global__ void __launch_bounds__(8) mymatmul_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN) {
  float T_matmul_NN_local[8192];
  __shared__ float data_shared[512];
  __shared__ float kernel_shared[512];
  for (int i_c_outer_inner_init = 0; i_c_outer_inner_init < 2; ++i_c_outer_inner_init) {
    for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 2; ++j_c_outer_inner_init) {
      for (int i_c_inner_init = 0; i_c_inner_init < 64; ++i_c_inner_init) {
        for (int j_c_inner_init = 0; j_c_inner_init < 32; ++j_c_inner_init) {
          T_matmul_NN_local[((((i_c_outer_inner_init * 4096) + (i_c_inner_init * 64)) + (j_c_outer_inner_init * 32)) + j_c_inner_init)] = 0.000000e+00f;
        }
      }
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 512; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 64; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 8) + ((int)threadIdx.x))] = data[((((((((int)blockIdx.x) >> 4) * 262144) + (ax0_ax1_fused_outer_outer * 4096)) + ((((int)threadIdx.x) >> 1) * 1024)) + (k_outer_outer * 2)) + (((int)threadIdx.x) & 1))];
    }
    for (int ax0_ax1_fused_outer_outer_1 = 0; ax0_ax1_fused_outer_outer_1 < 64; ++ax0_ax1_fused_outer_outer_1) {
      kernel_shared[((ax0_ax1_fused_outer_outer_1 * 8) + ((int)threadIdx.x))] = kernel[(((((k_outer_outer * 8192) + ((ax0_ax1_fused_outer_outer_1 >> 5) * 4096)) + ((((int)blockIdx.x) & 15) * 256)) + ((ax0_ax1_fused_outer_outer_1 & 31) * 8)) + ((int)threadIdx.x))];
    }
    __syncthreads();
    for (int i_c_outer_inner = 0; i_c_outer_inner < 2; ++i_c_outer_inner) {
      for (int j_c_outer_inner = 0; j_c_outer_inner < 2; ++j_c_outer_inner) {
        for (int k_inner = 0; k_inner < 2; ++k_inner) {
          for (int i_c_inner = 0; i_c_inner < 64; ++i_c_inner) {
            for (int j_c_inner = 0; j_c_inner < 32; ++j_c_inner) {
              T_matmul_NN_local[((((i_c_outer_inner * 4096) + (i_c_inner * 64)) + (j_c_outer_inner * 32)) + j_c_inner)] = (T_matmul_NN_local[((((i_c_outer_inner * 4096) + (i_c_inner * 64)) + (j_c_outer_inner * 32)) + j_c_inner)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 256) + (i_c_outer_inner * 128)) + (i_c_inner * 2)) + k_inner)] * kernel_shared[((((k_inner * 256) + ((((int)threadIdx.x) & 3) * 64)) + (j_c_outer_inner * 32)) + j_c_inner)]));
            }
          }
        }
      }
    }
  }
  for (int i_inner = 0; i_inner < 128; ++i_inner) {
    for (int j_inner = 0; j_inner < 64; ++j_inner) {
      T_matmul_NN[(((((((((int)blockIdx.x) >> 4) * 1048576) + ((((int)threadIdx.x) >> 2) * 524288)) + (i_inner * 4096)) + ((((int)blockIdx.x) & 15) * 256)) + ((((int)threadIdx.x) & 3) * 64)) + j_inner)] = T_matmul_NN_local[((i_inner * 64) + j_inner)];
    }
  }
}

