#!/bin/bash
#SBATCH --job-name=tree_test
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:15:00

set -euo pipefail

module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/test_tree_small.varsites.phy"

iqtree2 \
    -s "$INPUT" \
    -st DNA \
    -m GTR+ASC \
    -T 2 \
    --seed 47 \
    --prefix test_tree_small_asc
