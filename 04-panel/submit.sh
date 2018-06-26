#!/bin/bash -e

#SBATCH -J panel
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake-himem
#SBATCH --time=11:55:00

srun -n 1 panel.sh $1
