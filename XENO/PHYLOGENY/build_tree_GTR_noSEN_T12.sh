#!/bin/bash
#SBATCH --job-name=tree_GTR_T12
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=128G
#SBATCH --time=72:00:00

set -euo pipefail
module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/phylip_output/house_sparrow_no_SEN0002U.phy"
PREFIX="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/house_sparrow_noSEN_GTR_T12"

echo "Starting: $(date)"
iqtree2 --version | head -n 1
iqtree2 -s "$INPUT" -st DNA -m GTR -B 1000 -T 12 --seed 47 --prefix "$PREFIX"
echo "Finished: $(date)"
