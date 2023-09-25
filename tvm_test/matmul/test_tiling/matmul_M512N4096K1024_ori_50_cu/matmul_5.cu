
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
  float T_matmul_NN_local[8];
  __shared__ float data_shared[2048];
  __shared__ float kernel_shared[256];
  for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 4; ++j_c_outer_inner_init) {
    T_matmul_NN_local[j_c_outer_inner_init] = 0.000000e+00f;
    T_matmul_NN_local[(j_c_outer_inner_init + 4)] = 0.000000e+00f;
  }
  for (int k_outer_outer = 0; k_outer_outer < 64; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 8; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 256) + ((int)threadIdx.x))] = data[((((((((int)blockIdx.x) >> 8) * 131072) + (ax0_ax1_fused_outer_outer * 16384)) + ((((int)threadIdx.x) >> 4) * 1024)) + (k_outer_outer * 16)) + (((int)threadIdx.x) & 15))];
    }
    kernel_shared[((int)threadIdx.x)] = kernel[((((k_outer_outer * 65536) + ((((int)threadIdx.x) >> 4) * 4096)) + ((((int)blockIdx.x) & 255) * 16)) + (((int)threadIdx.x) & 15))];
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 4; ++k_outer_inner) {
      for (int j_c_outer_inner = 0; j_c_outer_inner < 4; ++j_c_outer_inner) {
        for (int k_inner = 0; k_inner < 4; ++k_inner) {
          T_matmul_NN_local[j_c_outer_inner] = (T_matmul_NN_local[j_c_outer_inner] + (data_shared[((((((int)threadIdx.x) >> 2) * 16) + (k_outer_inner * 4)) + k_inner)] * kernel_shared[((((k_outer_inner * 64) + (k_inner * 16)) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner)]));
          T_matmul_NN_local[(j_c_outer_inner + 4)] = (T_matmul_NN_local[(j_c_outer_inner + 4)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 16) + (k_outer_inner * 4)) + k_inner) + 1024)] * kernel_shared[((((k_outer_inner * 64) + (k_inner * 16)) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner)]));
        }
      }
    }
  }
  for (int j_inner = 0; j_inner < 4; ++j_inner) {
    T_matmul_NN[((((((((int)blockIdx.x) >> 8) * 524288) + ((((int)threadIdx.x) >> 2) * 4096)) + ((((int)blockIdx.x) & 255) * 16)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner)] = T_matmul_NN_local[j_inner];
    T_matmul_NN[(((((((((int)blockIdx.x) >> 8) * 524288) + ((((int)threadIdx.x) >> 2) * 4096)) + ((((int)blockIdx.x) & 255) * 16)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner) + 262144)] = T_matmul_NN_local[(j_inner + 4)];
  }
}

