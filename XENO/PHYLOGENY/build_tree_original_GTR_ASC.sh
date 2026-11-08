#!/bin/bash
#SBATCH --job-name=tree_GTR_ASC
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=72:00:00

set -euo pipefail

module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/phylip_output/house_sparrow.min4.phy"

PREFIX="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/house_sparrow_original_GTR_ASC"

echo "Starting IQ-TREE analysis"
date
echo "IQ-TREE version:"
iqtree2 --version
echo "Input alignment: $INPUT"
echo "Output prefix: $PREFIX"

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input alignment not found: $INPUT"
    exit 1
fi

iqtree2 \
    -s "$INPUT" \
    -st DNA \
    -m GTR+ASC \
    -B 1000 \
    -T 4 \
    --seed 47 \
    --prefix "$PREFIX"

echo "IQ-TREE analysis finished"
date
