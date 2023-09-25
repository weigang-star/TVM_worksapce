
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
extern "C" __global__ void __launch_bounds__(512) mymatmul_kernel0(float* __restrict__ data, float* __restrict__ kernel, float* __restrict__ T_matmul_NN) {
  float T_matmul_NN_local[8];
  __shared__ float data_shared[4096];
  __shared__ float kernel_shared[64];
  for (int i_c_outer_inner_init = 0; i_c_outer_inner_init < 2; ++i_c_outer_inner_init) {
    for (int i_c_inner_init = 0; i_c_inner_init < 2; ++i_c_inner_init) {
      T_matmul_NN_local[((i_c_outer_inner_init * 2) + i_c_inner_init)] = 0.000000e+00f;
      T_matmul_NN_local[(((i_c_outer_inner_init * 2) + i_c_inner_init) + 4)] = 0.000000e+00f;
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 128; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 8; ++ax0_ax1_fused_outer_outer) {
      data_shared[((ax0_ax1_fused_outer_outer * 512) + ((int)threadIdx.x))] = data[((((ax0_ax1_fused_outer_outer * 65536) + ((((int)threadIdx.x) >> 3) * 1024)) + (k_outer_outer * 8)) + (((int)threadIdx.x) & 7))];
    }
    if (((int)threadIdx.x) < 16) {
      *(float4*)(kernel_shared + (((int)threadIdx.x) * 4)) = *(float4*)(kernel + ((((k_outer_outer * 32768) + ((((int)threadIdx.x) >> 1) * 4096)) + (((int)blockIdx.x) * 8)) + ((((int)threadIdx.x) & 1) * 4)));
    }
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 8; ++k_outer_inner) {
      for (int i_c_outer_inner = 0; i_c_outer_inner < 2; ++i_c_outer_inner) {
        for (int i_c_inner = 0; i_c_inner < 2; ++i_c_inner) {
          T_matmul_NN_local[((i_c_outer_inner * 2) + i_c_inner)] = (T_matmul_NN_local[((i_c_outer_inner * 2) + i_c_inner)] + (data_shared[(((((((int)threadIdx.x) >> 3) * 32) + (i_c_outer_inner * 16)) + (i_c_inner * 8)) + k_outer_inner)] * kernel_shared[((k_outer_inner * 8) + (((int)threadIdx.x) & 7))]));
          T_matmul_NN_local[(((i_c_outer_inner * 2) + i_c_inner) + 4)] = (T_matmul_NN_local[(((i_c_outer_inner * 2) + i_c_inner) + 4)] + (data_shared[((((((((int)threadIdx.x) >> 3) * 32) + (i_c_outer_inner * 16)) + (i_c_inner * 8)) + k_outer_inner) + 2048)] * kernel_shared[((k_outer_inner * 8) + (((int)threadIdx.x) & 7))]));
        }
      }
    }
  }
  for (int i_inner = 0; i_inner < 4; ++i_inner) {
    T_matmul_NN[(((((((int)threadIdx.x) >> 3) * 16384) + (i_inner * 4096)) + (((int)blockIdx.x) * 8)) + (((int)threadIdx.x) & 7))] = T_matmul_NN_local[i_inner];
    T_matmul_NN[((((((((int)threadIdx.x) >> 3) * 16384) + (i_inner * 4096)) + (((int)blockIdx.x) * 8)) + (((int)threadIdx.x) & 7)) + 1048576)] = T_matmul_NN_local[(i_inner + 4)];
  }
}

