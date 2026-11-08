#!/bin/bash
#SBATCH --job-name=PCA_MAF05
#SBATCH --account=nn10082k
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --output=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/filter_maf05_%j.out
#SBATCH --error=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/filter_maf05_%j.err

set -euo pipefail

# Load software
module --force purge
module load StdEnv
module load VCFtools/0.1.16-GCC-12.2.0
module load BCFtools/1.17-GCC-12.2.0

# Input: existing XENO-filtered VCF
INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# Output directory for the separate PCA dataset
OUTDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05"

# Output file
OUTPUT="${OUTDIR}/variants_default_filters_MAF05.vcf.gz"

# Create output directory
mkdir -p "$OUTDIR"

# Check that the input exists
if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input VCF not found: $INPUT"
    exit 1
fi

# Apply MAF >= 0.05 and write a compressed VCF
vcftools \
    --gzvcf "$INPUT" \
    --maf 0.05 \
    --recode \
    --stdout \
    | bcftools view --threads 2 -Oz -o "$OUTPUT"

# Index the output VCF
bcftools index --threads 2 "$OUTPUT"

echo "MAF filtering completed successfully."
echo "Output VCF: $OUTPUT"
echo "Output index: ${OUTPUT}.csi"
