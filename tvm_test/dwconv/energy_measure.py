import random
import time
import json
import subprocess
import psutil
import os
from shutil import copyfile

name = 'dwconv_N128C128H28W28_energy_1000_2'

workdir = './_tmp/'
op = 'dwconv'

json_dir = name + '_json'
if not os.path.exists(json_dir): os.mkdir(json_dir)
cu_dir = name + '_cu'
if not os.path.exists(cu_dir): os.mkdir(cu_dir)
gridblk_dir = name + '_gridblk'
if not os.path.exists(gridblk_dir): os.mkdir(gridblk_dir)
ncu_dir = name + '_ncu'
if not os.path.exists(ncu_dir): os.mkdir(ncu_dir)
kernel_cu_dir = name + '_kernel_cu'
if not os.path.exists(kernel_cu_dir): os.mkdir(kernel_cu_dir)
power_data_dir = 'power_data_' + name
if not os.path.exists(power_data_dir): os.mkdir(power_data_dir)
power_sample_dir = 'power_sample_' + name
if not os.path.exists(power_sample_dir): os.mkdir(power_sample_dir)
temperature_dir = 'temperature_' + name
if not os.path.exists(temperature_dir): os.mkdir(temperature_dir)

# json preprocess
json_preprocess = False
if json_preprocess:
    json_in = open(name + '.json', 'r')
    lines = json_in.read().split('\n')

    for i, line in enumerate(lines):
        json_out = open(os.path.join(json_dir, op + '_' + str(i) + '.json'), 'w')
        json_out.write(lines[i])
        json_out.close()
    json_in.close()

# run_list = range(0, 1000)
# run_list = [831,767,575,639,576,768,640,447,703,511,577,641,704,832,383,578,642,579,643,644,705,833,834,769,835,770,580,581,582,384,583,771,512,895,448,584,449,947,706,772,645,896,646,585,707,450,451,773,586,385,452,587,588,647,648,513,386,453,708,836,837,838,649,774,589,775,514,387,590,515,839,516,840,709,517,897,650,841,388,710,711,776,591,842,389,518,592,519,390,520,454,593,948,594,595,777,455,778,596,843,]
run_list = [647,768,773]
for index in run_list: 
    print('index =', index)
    json_path = os.path.join(json_dir, op + '_' + str(index) + '.json')
    rerun_path = os.path.join(workdir, op + '_rerun.py')
    cu_path = os.path.join(workdir, op + '.cu')
    gridblk_path = os.path.join(workdir, op + '_gridblk')
    latency_path = os.path.join(workdir, op + '_latency')
    metrics_path = os.path.join(workdir, op + '_metrics')
    kernel_cu_template_path = os.path.join(workdir, op + '_kernel_template.cu')
    kernel_cu_path = os.path.join(workdir, op + '_kernel.cu')

    HEADERNVMLAPI = '-lnvidia-ml -L/usr/local/cuda-11.0/lib64 -lcuda -I/usr/local/cuda-11.0/include -lpthread -I/data/kernel-energy/nvml-power'
    INCLUDEPROG = '/data/kernel-energy/nvml-power/nvmlPower.cpp'

    # invalid, continue
    with open(json_path) as json_in:
        line = json_in.readline()
    injson = json.loads(line)
    if injson['r'][0][0] >= 1e+10 or injson['r'][1] != 0:
        print('Invalid result, continue')
        continue

    # generate gridblk and cuda src
    command_gridblk_cu = 'python ' + rerun_path + ' --config1 ' + json_path + ' --config2 ' + cu_path + ' > ' + gridblk_path
    print(command_gridblk_cu)
    os.system(command_gridblk_cu)
    copyfile(cu_path, os.path.join(cu_dir, op + '_' + str(index) + '.cu'))
    copyfile(gridblk_path, os.path.join(gridblk_dir, op + '_' + str(index)))

    # generate latency
    command_latency = 'nvprof --log-file ' + latency_path + ' python ' + rerun_path + ' --config1 ' + json_path + ' > /dev/null'
    print(command_latency)
    os.system(command_latency)
    copyfile(latency_path, os.path.join(ncu_dir, op + '_' + str(index) + '_latency'))

    # get latency
    get_latency = False
    file_latency = open(latency_path)
    while True:
        text = file_latency.readline()
        if text == "": break
        # print(text)
        text = text.split()
        if len(text) == 0: continue
        if text[-1].endswith("kernel0"):
            if text[-6][-2:]=='us': base = 1e-6
            elif text[-6][-2:]=='ms': base = 1e-3
            else: print('error!')
            latency = float(text[-6][:-2])*base # s
            get_latency = True
            break
    file_latency.close()
    if get_latency: 
        print('latency =', latency)
    else:
        print('fail to get latency')
        latency = 10.0 + random.random() # 10s, as default timeout

    # generate other nvprof metrics
    query_list = "dram_read_transactions,dram_write_transactions,l2_read_transactions,l2_write_transactions,shared_load_transactions,shared_store_transactions,flop_count_sp_fma,flop_sp_efficiency,sm_efficiency"
    query_list_mem_throughput = ",dram_read_throughput,dram_write_throughput,l2_read_throughput,l2_write_throughput,shared_load_throughput,shared_store_throughput"
    command_metrics = 'nvprof --metrics \"' + query_list + '\" --log-file ' + metrics_path + ' python ' + rerun_path + ' --config1 ' + json_path + ' > /dev/null'
    print(command_metrics)
    os.system(command_metrics)
    copyfile(metrics_path, os.path.join(ncu_dir, op + '_' + str(index) + '_metrics'))

    # copy kernel cuda
    command_copy_kernel = 'cp ' + kernel_cu_template_path + ' ' + kernel_cu_path
    print(command_copy_kernel)
    os.system(command_copy_kernel)

    # add gridblk and declaration to kernel cuda
    RUNTIME = 20 # s
    repeat_times = int(RUNTIME / latency)
    print('add gridblk & repeat, repeat = ', repeat_times)

    file_gridblk = open(gridblk_path, 'r')
    file_kernel_cu_template = open(kernel_cu_template_path, 'r')
    file_cu = open(cu_path, 'r')
    file_kernel_cu = open(kernel_cu_path, 'w')

    grid = file_gridblk.readline().split()
    blk = file_gridblk.readline().split()
    content = file_kernel_cu_template.read()
    while True:
        line = file_cu.readline()
        if not line: break
        line = line.split()
        if len(line) == 0: continue
        if(line[0] == 'extern'):
            declare = ' '.join(line[:-1]) + ';\n'
            break

    file_kernel_cu.write('#define REPEAT ' + str(repeat_times) + '\n')
    file_kernel_cu.write('dim3 dimGrid(' + grid[0] + ', ' + grid[1] + ', ' + grid[2] + ');\n')
    file_kernel_cu.write('dim3 dimBlock(' + blk[0] + ', ' + blk[1] + ', ' + blk[2] + ');\n')
    file_kernel_cu.write(declare + '\n')
    file_kernel_cu.write(content)

    file_gridblk.close()
    file_kernel_cu.close()
    file_kernel_cu_template.close()
    copyfile(kernel_cu_path, os.path.join(kernel_cu_dir, op + '_kernel_' + str(index) + '.cu'))

    # build
    command_make = 'nvcc -o ' + op + '_o ' + cu_path + ' ' +  kernel_cu_path + ' ' + HEADERNVMLAPI + ' ' + INCLUDEPROG
    print(command_make)
    os.system(command_make)

    # run
    print('./' + op + '_o')
    TIMEOUT = RUNTIME * 2 # s
    subp = subprocess.Popen(['./' + op + '_o'])
    p = psutil.Process(subp.pid)
    try:
        p.wait(timeout=TIMEOUT)
        print('run finish')
    except psutil.TimeoutExpired:
        p.kill()
        print('run timeout(' + str(TIMEOUT) + 's), kill')

    # collect power result & energy
    file_power_sample=open("Power_data.txt")
    lines = file_power_sample.read()
    if len(lines) == 0: # warmup timeout(very slow kernel), use power=400W as error
        energy = 400 * latency * 1000
    else:
        lines = lines.split()
        sum = 0.0
        power_peak = 0
        for i in lines:
            power = float(i)
            sum += power
            if power > power_peak: power_peak = power
        power_avg = sum / len(lines) # w
        energy = power_avg * latency * 1000 # mJ
    file_power_sample.close()
    copyfile('Power_data.txt', os.path.join(power_sample_dir, 'power_sample_' + str(index)))
    copyfile('Temperature_data.txt', os.path.join(temperature_dir, 'temperature_' + str(index)))
    file_power_data = open(os.path.join(power_data_dir, 'power_data_' + str(index)), 'w')
    file_power_data.write(str(energy) + '\n')
    file_power_data.write(str(power_avg) + '\n')
    file_power_data.write(str(power_peak) + '\n')
    file_power_data.close()
    print('energy = %f, power_peak = %f, power_avg = %f' % (energy, power_peak, power_avg))
    print()
