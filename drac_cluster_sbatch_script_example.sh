#!/bin/bash
#SBATCH --cpus-per-task=4         # Ask for X CPUs
#SBATCH --gres=gpu:1              # Ask for X GPU
#SBATCH --mem=64G                 # Ask for X GB of RAM
#SBATCH --time=1:00:00            # The job will run for h
#SBATCH --account=<YOUR_SUPERVISOR_ACCOUNT>

rsync -avz /project/<YOUR_SUPERVISOR_ACCOUNT>/<YOUR_USERNAME>/Singularity/my_image.sif $SLURM_TMPDIR

module load apptainer/1.3.5
module load httpproxy
module load cuda/12.6

apptainer run --nv \
  --env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH \
  -B ~/nvidia-bind/libEGL_nvidia.so.0:/usr/lib/x86_64-linux-gnu/libEGL_nvidia.so.0 \
  -B ~/nvidia-bind/libGLX_nvidia.so.0:/usr/lib/x86_64-linux-gnu/libGLX_nvidia.so.0 \
  -B ~/nvidia-bind/libnvidia-allocator.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.1 \
  -B ~/nvidia-bind/libnvidia-allocator.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-allocator.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-api.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-api.so.1 \
  -B ~/nvidia-bind/libnvidia-cfg.so:/usr/lib/x86_64-linux-gnu/libnvidia-cfg.so \
  -B ~/nvidia-bind/libnvidia-cfg.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-cfg.so.1 \
  -B ~/nvidia-bind/libnvidia-cfg.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-cfg.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-eglcore.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-eglcore.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-egl-gbm.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-gbm.so.1 \
  -B ~/nvidia-bind/libnvidia-egl-gbm.so.1.1.2:/usr/lib/x86_64-linux-gnu/libnvidia-egl-gbm.so.1.1.2 \
  -B ~/nvidia-bind/libnvidia-egl-wayland.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-wayland.so.1 \
  -B ~/nvidia-bind/libnvidia-egl-wayland.so.1.1.19:/usr/lib/x86_64-linux-gnu/libnvidia-egl-wayland.so.1.1.19 \
  -B ~/nvidia-bind/libnvidia-egl-xcb.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-xcb.so.1 \
  -B ~/nvidia-bind/libnvidia-egl-xcb.so.1.0.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-xcb.so.1.0.1 \
  -B ~/nvidia-bind/libnvidia-egl-xlib.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-xlib.so.1 \
  -B ~/nvidia-bind/libnvidia-egl-xlib.so.1.0.1:/usr/lib/x86_64-linux-gnu/libnvidia-egl-xlib.so.1.0.1 \
  -B ~/nvidia-bind/libnvidia-encode.so:/usr/lib/x86_64-linux-gnu/libnvidia-encode.so \
  -B ~/nvidia-bind/libnvidia-encode.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-encode.so.1 \
  -B ~/nvidia-bind/libnvidia-encode.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-encode.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-fbc.so:/usr/lib/x86_64-linux-gnu/libnvidia-fbc.so \
  -B ~/nvidia-bind/libnvidia-fbc.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.1 \
  -B ~/nvidia-bind/libnvidia-fbc.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-fbc.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-glcore.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-glcore.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-glsi.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-glsi.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-glvkspirv.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-glvkspirv.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-gpucomp.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-gpucomp.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-gtk3.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-gtk3.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-ml.so:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so \
  -B ~/nvidia-bind/libnvidia-ml.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 \
  -B ~/nvidia-bind/libnvidia-ml.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-ml.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-nvvm.so:/usr/lib/x86_64-linux-gnu/libnvidia-nvvm.so \
  -B ~/nvidia-bind/libnvidia-nvvm.so.4:/usr/lib/x86_64-linux-gnu/libnvidia-nvvm.so.4 \
  -B ~/nvidia-bind/libnvidia-nvvm.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-nvvm.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-opencl.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.1 \
  -B ~/nvidia-bind/libnvidia-opencl.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-opencl.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-opticalflow.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-opticalflow.so.1 \
  -B ~/nvidia-bind/libnvidia-opticalflow.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-opticalflow.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-pkcs11.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-pkcs11.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-ptxjitcompiler.so:/usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so \
  -B ~/nvidia-bind/libnvidia-ptxjitcompiler.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.1 \
  -B ~/nvidia-bind/libnvidia-ptxjitcompiler.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-ptxjitcompiler.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-rtcore.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-rtcore.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-sandboxutils.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-sandboxutils.so.1 \
  -B ~/nvidia-bind/libnvidia-sandboxutils.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-sandboxutils.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-tls.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-tls.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-vksc-core.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-vksc-core.so.1 \
  -B ~/nvidia-bind/libnvidia-vksc-core.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-vksc-core.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-ngx.so.1:/usr/lib/x86_64-linux-gnu/libnvidia-ngx.so.1 \
  -B ~/nvidia-bind/libnvidia-ngx.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-ngx.so.570.148.08 \
  -B ~/nvidia-bind/libnvidia-wayland-client.so.570.148.08:/usr/lib/x86_64-linux-gnu/libnvidia-wayland-client.so.570.148.08 \
  -B ~/nvidia-bind/libvulkan.so.1:/usr/lib/x86_64-linux-gnu/libvulkan.so.1 \
  -B ~/nvidia-bind/libvulkan.so.1.3.283:/usr/lib/x86_64-linux-gnu/libvulkan.so.1.3.283 \
  -B ~/nvidia-bind/libGLX_nvidia.so.0:/usr/lib64/libGLX_nvidia.so.0 \
  --bind /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:/usr/share/vulkan/icd.d/nvidia_icd.json \
  --bind /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json \
  --bind /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
  --bind <YOUR_CODE>:/code/ \
  --bind $SLURM_TMPDIR:/dataset/ \
  --bind $SLURM_TMPDIR:/tmp_job_data/ \
  --bind $SCRATCH:/final_job_data/ \
  $SLURM_TMPDIR/my_image.sif python scripts/train_rl.py
