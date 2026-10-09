#!/bin/bash

#SBATCH --job-name=XENO_map
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k

#SBATCH --nodes=1
#SBATCH --tasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=120:00:00

module --quiet purge
module load Miniconda3/22.11.1-1

source /cluster/home/melatag/miniconda3/etc/profile.d/conda.sh
conda activate nf

echo "Conda environment:"
which python
echo "Nextflow:"
nextflow -version

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO

bash ./XENO
