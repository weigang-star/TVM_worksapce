
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
  float T_matmul_NN_local[256];
  __shared__ float data_shared[2048];
  __shared__ float kernel_shared[512];
  for (int i_c_outer_inner_init = 0; i_c_outer_inner_init < 2; ++i_c_outer_inner_init) {
    for (int j_c_outer_inner_init = 0; j_c_outer_inner_init < 4; ++j_c_outer_inner_init) {
      for (int i_c_inner_init = 0; i_c_inner_init < 8; ++i_c_inner_init) {
        T_matmul_NN_local[(((i_c_outer_inner_init * 32) + (i_c_inner_init * 4)) + j_c_outer_inner_init)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_outer_inner_init * 32) + (i_c_inner_init * 4)) + j_c_outer_inner_init) + 64)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_outer_inner_init * 32) + (i_c_inner_init * 4)) + j_c_outer_inner_init) + 128)] = 0.000000e+00f;
        T_matmul_NN_local[((((i_c_outer_inner_init * 32) + (i_c_inner_init * 4)) + j_c_outer_inner_init) + 192)] = 0.000000e+00f;
      }
    }
  }
  for (int k_outer_outer = 0; k_outer_outer < 128; ++k_outer_outer) {
    __syncthreads();
    for (int ax0_ax1_fused_inner_s = 0; ax0_ax1_fused_inner_s < 64; ++ax0_ax1_fused_inner_s) {
      if (((int)threadIdx.x) < 32) {
        data_shared[((((int)threadIdx.x) * 64) + ax0_ax1_fused_inner_s)] = data[((((((((int)blockIdx.x) >> 6) * 262144) + (((int)threadIdx.x) * 8192)) + ((ax0_ax1_fused_inner_s >> 3) * 1024)) + (k_outer_outer * 8)) + (ax0_ax1_fused_inner_s & 7))];
      }
    }
    for (int ax0_ax1_fused_outer_outer = 0; ax0_ax1_fused_outer_outer < 4; ++ax0_ax1_fused_outer_outer) {
      *(float2*)(kernel_shared + ((ax0_ax1_fused_outer_outer * 128) + (((int)threadIdx.x) * 2))) = *(float2*)(kernel + (((((k_outer_outer * 32768) + (ax0_ax1_fused_outer_outer * 8192)) + ((((int)threadIdx.x) >> 5) * 4096)) + ((((int)blockIdx.x) & 63) * 64)) + ((((int)threadIdx.x) & 31) * 2)));
    }
    __syncthreads();
    for (int k_outer_inner = 0; k_outer_inner < 8; ++k_outer_inner) {
      for (int i_c_outer_inner = 0; i_c_outer_inner < 2; ++i_c_outer_inner) {
        for (int j_c_outer_inner = 0; j_c_outer_inner < 4; ++j_c_outer_inner) {
          for (int i_c_inner = 0; i_c_inner < 8; ++i_c_inner) {
            T_matmul_NN_local[(((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner)] = (T_matmul_NN_local[(((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 128) + (i_c_outer_inner * 64)) + (i_c_inner * 8)) + k_outer_inner)] * kernel_shared[(((k_outer_inner * 64) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner)]));
            T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 64)] = (T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 64)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 128) + (i_c_outer_inner * 64)) + (i_c_inner * 8)) + k_outer_inner)] * kernel_shared[((((k_outer_inner * 64) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner) + 16)]));
            T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 128)] = (T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 128)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 128) + (i_c_outer_inner * 64)) + (i_c_inner * 8)) + k_outer_inner)] * kernel_shared[((((k_outer_inner * 64) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner) + 32)]));
            T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 192)] = (T_matmul_NN_local[((((i_c_outer_inner * 32) + (i_c_inner * 4)) + j_c_outer_inner) + 192)] + (data_shared[(((((((int)threadIdx.x) >> 2) * 128) + (i_c_outer_inner * 64)) + (i_c_inner * 8)) + k_outer_inner)] * kernel_shared[((((k_outer_inner * 64) + ((((int)threadIdx.x) & 3) * 4)) + j_c_outer_inner) + 48)]));
          }
        }
      }
    }
  }
  for (int i_inner = 0; i_inner < 16; ++i_inner) {
    for (int j_inner = 0; j_inner < 4; ++j_inner) {
      T_matmul_NN[(((((((((int)blockIdx.x) >> 6) * 1048576) + ((((int)threadIdx.x) >> 2) * 65536)) + (i_inner * 4096)) + ((((int)blockIdx.x) & 63) * 64)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner)] = T_matmul_NN_local[((i_inner * 4) + j_inner)];
      T_matmul_NN[((((((((((int)blockIdx.x) >> 6) * 1048576) + ((((int)threadIdx.x) >> 2) * 65536)) + (i_inner * 4096)) + ((((int)blockIdx.x) & 63) * 64)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner) + 16)] = T_matmul_NN_local[(((i_inner * 4) + j_inner) + 64)];
      T_matmul_NN[((((((((((int)blockIdx.x) >> 6) * 1048576) + ((((int)threadIdx.x) >> 2) * 65536)) + (i_inner * 4096)) + ((((int)blockIdx.x) & 63) * 64)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner) + 32)] = T_matmul_NN_local[(((i_inner * 4) + j_inner) + 128)];
      T_matmul_NN[((((((((((int)blockIdx.x) >> 6) * 1048576) + ((((int)threadIdx.x) >> 2) * 65536)) + (i_inner * 4096)) + ((((int)blockIdx.x) & 63) * 64)) + ((((int)threadIdx.x) & 3) * 4)) + j_inner) + 48)] = T_matmul_NN_local[(((i_inner * 4) + j_inner) + 192)];
    }
  }
}

