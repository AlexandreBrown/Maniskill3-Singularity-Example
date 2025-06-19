#!/bin/bash
#SBATCH --cpus-per-task=4         # Ask for X CPUs
#SBATCH --gres=gpu:1              # Ask for X GPU
#SBATCH --mem=32G                 # Ask for X GB of RAM
#SBATCH --time=1:00:00            # The job will run for h

rsync -avz $SCRATCH/containers/my_image.sif $SLURM_TMPDIR

module load singularity
module load cuda/12.4.0/cudnn/9.3

singularity run \
        --nv \
        -B $HOME:/code/ \
        -B $SLURM_TMPDIR:/dataset/ \
        -B $SLURM_TMPDIR:/tmp_job_data/ \
        -B $SCRATCH:/final_job_data/ \
        $SLURM_TMPDIR/my_image.sif \
        python scripts/train_rl.py