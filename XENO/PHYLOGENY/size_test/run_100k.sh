#!/bin/bash
#SBATCH --job-name=size_100k
#SBATCH --output=size_test/SLURM-%j-%x.out
#SBATCH --error=size_test/SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=04:00:00
module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a
iqtree2 -s size_test/aln_100k.phy -st DNA -m GTR -T 4 --seed 47 --prefix size_test/out_100k
