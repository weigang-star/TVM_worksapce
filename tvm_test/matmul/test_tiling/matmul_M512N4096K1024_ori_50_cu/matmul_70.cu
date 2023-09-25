
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
extern "C" __global__ void __launch_bounds__(256) mymatmul_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN) {
  float T_matmul_NN_local[512];
  __shared__ float data_shared[2048];
  __shared__ float kernel_shared[1024];
  for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 4; ++j_c_outer_inner_init) {
    for (int i_c_inner_init = 0; i_c_inner_init < 16; ++i_c_inner_init) {
      for (int j_c_inner_init = 0; j_c_inner_init < 4; ++j_c_inner_init) {
        T_matmul_NN_local[(((i_c_inner_init * 16) + (j_c_outer_inner_init * 4)) + j_c_inner_init)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_inner_init * 16) + (j_c_outer_inner_init * 4)) + j_c_inner_init) + 256)] = 0.000000e+00f;
      }
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 256; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 8; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 256) + ((int)threadIdx.x))] = data[((((ax0_ax1_fused_outer_outer * 65536) + ((((int)threadIdx.x) >> 2) * 1024)) + (k_outer_outer * 4)) + (((int)threadIdx.x) & 3))];
    }
    for (int ax0_ax1_fused_outer_outer_1 = 0; ax0_ax1_fused_outer_outer_1 < 4; ++ax0_ax1_fused_outer_outer_1) {
      kernel_shared[((ax0_ax1_fused_outer_outer_1 * 256) + ((int)threadIdx.x))] = kernel[((((k_outer_outer * 16384) + (ax0_ax1_fused_outer_outer_1 * 4096)) + (((int)blockIdx.x) * 256)) + ((int)threadIdx.x))];
    }
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 4; ++k_outer_inner) {
      for (int j_c_outer_inner = 0; j_c_outer_inner < 4; ++j_c_outer_inner) {
        for (int i_c_inner = 0; i_c_inner < 16; ++i_c_inner) {
          for (int j_c_inner = 0; j_c_inner < 4; ++j_c_inner) {
            T_matmul_NN_local[(((i_c_inner * 16) + (j_c_outer_inner * 4)) + j_c_inner)] = (T_matmul_NN_local[(((i_c_inner * 16) + (j_c_outer_inner * 4)) + j_c_inner)] + (data_shared[((((((int)threadIdx.x) >> 4) * 64) + (i_c_inner * 4)) + k_outer_inner)] * kernel_shared[((((k_outer_inner * 256) + ((((int)threadIdx.x) & 15) * 16)) + (j_c_outer_inner * 4)) + j_c_inner)]));
            T_matmul_NN_local[((((i_c_inner * 16) + (j_c_outer_inner * 4)) + j_c_inner) + 256)] = (T_matmul_NN_local[((((i_c_inner * 16) + (j_c_outer_inner * 4)) + j_c_inner) + 256)] + (data_shared[(((((((int)threadIdx.x) >> 4) * 64) + (i_c_inner * 4)) + k_outer_inner) + 1024)] * kernel_shared[((((k_outer_inner * 256) + ((((int)threadIdx.x) & 15) * 16)) + (j_c_outer_inner * 4)) + j_c_inner)]));
          }
        }
      }
    }
  }
  for (int i_inner = 0; i_inner < 16; ++i_inner) {
    for (int j_inner = 0; j_inner < 16; ++j_inner) {
      T_matmul_NN[((((((((int)threadIdx.x) >> 4) * 65536) + (i_inner * 4096)) + (((int)blockIdx.x) * 256)) + ((((int)threadIdx.x) & 15) * 16)) + j_inner)] = T_matmul_NN_local[((i_inner * 16) + j_inner)];
      T_matmul_NN[(((((((((int)threadIdx.x) >> 4) * 65536) + (i_inner * 4096)) + (((int)blockIdx.x) * 256)) + ((((int)threadIdx.x) & 15) * 16)) + j_inner) + 1048576)] = T_matmul_NN_local[(((i_inner * 16) + j_inner) + 256)];
    }
  }
}

