#!/bin/bash
#SBATCH --job-name=PCA_MAF05_auto
#SBATCH --account=nn10082k
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=2
#SBATCH --output=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_auto_MAF05/filter_maf05_auto_%j.out
#SBATCH --error=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_auto_MAF05/filter_maf05_auto_%j.err

set -euo pipefail

# Load software
module --force purge
module load StdEnv
module load VCFtools/0.1.16-GCC-12.2.0
module load BCFtools/1.17-GCC-12.2.0

# Input: existing XENO-filtered VCF
INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# NEW: samples to remove (PMON + ITA), one sample name per line (vcftools format)
REMOVE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/remove_samples.txt"

# NEW: sex chromosomes to drop -- EDIT to match the names in your VCF
SEX_CHR=("chrZ" "chrW")

# NEW output directory and file name
OUTDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_auto_MAF05"
OUTPUT="${OUTDIR}/variants_PDOM_auto_MAF05.vcf.gz"

mkdir -p "$OUTDIR"

if [[ ! -f "$INPUT" ]]; then
    echo "ERROR: Input VCF not found: $INPUT"
    exit 1
fi

# Build --not-chr options for vcftools
NOT_CHR=()
for c in "${SEX_CHR[@]}"; do NOT_CHR+=(--not-chr "$c"); done

# Remove samples FIRST, drop Z/W, then MAF >= 0.05 (MAF now calculated on house sparrows only)
vcftools \
    --gzvcf "$INPUT" \
    --remove "$REMOVE" \
    "${NOT_CHR[@]}" \
    --maf 0.05 \
    --recode \
    --stdout \
    | bcftools view --threads 2 -Oz -o "$OUTPUT"

bcftools index --threads 2 "$OUTPUT"

# NEW
echo "Total SNPs in input VCF:          $(bcftools index -n "$INPUT")"
echo "Samples kept:                     $(bcftools query -l "$OUTPUT" | wc -l)"
echo "Autosomal SNPs with MAF >= 0.05:  $(bcftools index -n "$OUTPUT")"
echo "Output VCF: $OUTPUT"
