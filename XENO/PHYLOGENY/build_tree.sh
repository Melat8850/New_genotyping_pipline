#!/bin/bash
#SBATCH --job-name=build_tree
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=8G
#SBATCH --time=72:00:00

set -euo pipefail

module --quiet purge
module load IQ-TREE/2.2.2.7-gompi-2023a

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/phylip_output/house_sparrow_no_SEN0002U.phy"

iqtree2 \
    -s "$INPUT" \
    -st DNA \
    -m GTR+ASC \
    -B 1000 \
    -T 12 \
    --seed 47 \
    --prefix house_sparrow_tree
