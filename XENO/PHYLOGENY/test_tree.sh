#!/bin/bash
#SBATCH --job-name=test_tree
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=06:00:00

set -euo pipefail

module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/phylip_output/house_sparrow_no_SEN0002U.phy"

iqtree2 \
    -s "$INPUT" \
    -st DNA \
    -m GTR+ASC \
    -T 1 \
    --seed 47 \
    --prefix test_tree_240
