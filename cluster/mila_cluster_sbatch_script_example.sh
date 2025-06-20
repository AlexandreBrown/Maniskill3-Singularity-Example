#!/bin/bash
#SBATCH --cpus-per-task=4         # Ask for X CPUs
#SBATCH --gres=gpu:1              # Ask for X GPU
#SBATCH --mem=32G                 # Ask for X GB of RAM
#SBATCH --time=1:00:00            # The job will run for h

rsync -avz $SCRATCH/containers/my_image.sif $SLURM_TMPDIR

module load singularity
module load cuda/12.4.0/cudnn/9.3

# Since the host OS is the same as our container OS, the --nv flag will do its job
singularity run \
        --nv \
        --bind /etc/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json \
        --bind /etc/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json \
        --bind /usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \
        --bind $HOME:/code/ \
        --bind $SLURM_TMPDIR:/dataset/ \
        --bind $SLURM_TMPDIR:/tmp_job_data/ \
        --bind $SCRATCH:/final_job_data/ \
        $SLURM_TMPDIR/my_image.sif \
        python scripts/train_rl.py
