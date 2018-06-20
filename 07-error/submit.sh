#!/bin/bash -e

#SBATCH -J error
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=0:05:00

srun -n 1 error.sh
