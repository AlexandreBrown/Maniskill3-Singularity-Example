#!/bin/bash
# SBATCH --cpus-per-task=4         # Ask for X CPUs
# SBATCH --gres=gpu:1              # Ask for X GPU
# SBATCH --mem=64G                 # Ask for X GB of RAM
# SBATCH --time=1:00:00            # The job will run for h
# SBATCH --account=<YOUR_SUPERVISOR_ACCOUNT>

rsync -avz /project/def-<YOUR_SUPERVISOR_ACCOUNT>/<YOUR_USERNAME>/Singularity/my_image.sif $SLURM_TMPDIR

module load apptainer/1.3.5
module load httpproxy # This allows internet access for the logging libraries like CometML/W&B since DRAC clusters do not have internet access
module load cuda/12.6

lib_bind_flags=""

# The goal of this loop is to find all nvidia, egl, vulkan libs paths on the host
#   and create a --bind that will ensure the files are present at the appropriate location in our container
for host_lib in /usr/lib64/{libnvidia-*,libEGL_*,libGLX_*,libvulkan*}; do
  # skip if nothing matched
  [[ -e "$host_lib" ]] || continue

  name=$(basename "$host_lib")
  # map into Ubuntu-like path inside container
  container_lib="/usr/lib/x86_64-linux-gnu/$name"

  lib_bind_flags+=" --bind ${host_lib}:${container_lib}"
done

# [Host machine]: cat /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json
# Outputs something like this :
# {
#     "file_format_version" : "1.0.1",
#     "ICD": {
#         "library_path": "/usr/lib64/libGLX_nvidia.so.0",
#         "api_version" : "1.4.303"
#     }
# }
# Since json_file["ICD"]["library_path"] points to "/usr/lib64/libGLX_nvidia.so.0"
# We must also ensure the file is present at this exact location in our container (regardless of how the container OS structures libs)
lib_bind_flags+=" --bind /usr/lib64/libGLX_nvidia.so.0:/usr/lib64/libGLX_nvidia.so.0"

# Vulkan expects the following json files to be present in the container at runtime
# Note that if your host doesn't already have these than you can create the files manually and add them to your container
# See the following doc for example of what these files should be : https://maniskill.readthedocs.io/en/latest/user_guide/getting_started/installation.html#ubuntu
# Note that Narval cluster has the icd file on the host but since the name is nvidia_icd.x86_64.json Vulkan won't find it so we must ensure we bind it to nvidia_icd.json in the container
# This might be different on your cluster, in your case you might simply need to do --bind /usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json if the host has nvidia_icd.json
lib_bind_flags+=" --bind /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json:/usr/share/vulkan/icd.d/nvidia_icd.json"
lib_bind_flags+=" --bind /usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json"
lib_bind_flags+=" --bind /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json"

apptainer run --nv \
  --env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH \
  ${lib_bind_flags} \
  --bind <PATH_TO_FOLDER_WITH_YOUR_REPOS>:/code/ \
  --bind $SLURM_TMPDIR:/dataset/ \
  --bind $SLURM_TMPDIR:/tmp_job_data/ \
  --bind $SCRATCH:/final_job_data/ \
  $SLURM_TMPDIR/my_image.sif python scripts/train_rl.py
