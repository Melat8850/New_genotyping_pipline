#!/bin/bash
#SBATCH --job-name=LD_pruning
#SBATCH --account=nn10082k
#SBATCH --time=06:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=LD_pruning_%j.out
#SBATCH --error=LD_pruning_%j.err

set -euo pipefail

module load PLINK/1.9b_6.13-x86_64

# Base directories
BASE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO"
WORK="${BASE}/PCA_MAF05"

# Input VCF files
VCF_MAF05="${BASE}/output/PCA_MAF05/variants_default_filters_MAF05.vcf.gz"

VCF_DEFAULT="${BASE}/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# Sample removal list
REMOVE="${WORK}/remove_samples_plink.txt"

# Separate output directories
OUT_MAF05="${WORK}/PCA_MAF05_LD100kb"
OUT_DEFAULT="${WORK}/PCA_default_LD50kb"

# Check that input files exist
test -f "$VCF_MAF05"
test -f "$VCF_DEFAULT"
test -f "$REMOVE"

echo "=========================================="
echo "LD pruning for MAF 0.05 dataset"
echo "=========================================="

plink \
    --vcf "$VCF_MAF05" \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --remove "$REMOVE" \
    --indep-pairwise 100kb 1 0.1 \
    --out "${OUT_MAF05}/MAF05_LD100kb"

echo "=========================================="
echo "LD pruning for default-filtered dataset"
echo "=========================================="

plink \
    --vcf "$VCF_DEFAULT" \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --remove "$REMOVE" \
    --indep-pairwise 50kb 10 0.1 \
    --out "${OUT_DEFAULT}/default_LD50kb"

echo "=========================================="
echo "LD pruning completed for both datasets"
echo "=========================================="

echo "MAF 0.05 retained SNPs:"
wc -l "${OUT_MAF05}/MAF05_LD100kb.prune.in"

echo "Default-filtered retained SNPs:"
wc -l "${OUT_DEFAULT}/default_LD50kb.prune.in"

echo "MAF 0.05 excluded SNPs:"
wc -l "${OUT_MAF05}/MAF05_LD100kb.prune.out"

echo "Default-filtered excluded SNPs:"
wc -l "${OUT_DEFAULT}/default_LD50kb.prune.out"
