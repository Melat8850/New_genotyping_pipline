#!/bin/bash
#SBATCH --job-name=convert_tree
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=12:00:00

set -euo pipefail

module --quiet purge
module load Python/3.12.3-GCCcore-13.3.0

# Input VCF from the XENO pipeline
INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# Output directory for the phylogenetic alignment
OUTDIR="phylip_output"

# Convert VCF to PHYLIP format
python vcf2phylip.py \
    -i "$INPUT" \
    --output-folder "$OUTDIR" \
    --output-prefix house_sparrow
