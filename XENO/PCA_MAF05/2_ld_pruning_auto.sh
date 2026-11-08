#!/bin/bash
#SBATCH --job-name=LD_pruning_auto
#SBATCH --account=nn10082k
#SBATCH --time=06:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --output=LD_pruning_auto_%j.out
#SBATCH --error=LD_pruning_auto_%j.err

set -euo pipefail

module load PLINK/1.9b_6.13-x86_64

BASE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO"
WORK="${BASE}/PCA_auto_MAF05_LD100kb"

# NEW input: house sparrows only, autosomes, MAF 0.05 (from script 1)
VCF="${BASE}/output/PCA_auto_MAF05/variants_PDOM_auto_MAF05.vcf.gz"

mkdir -p "$WORK"
test -f "$VCF"

# --remove is no longer needed: samples were already removed in script 1
# NEW: --make-bed saves a binary copy so script 3 does not have to read the VCF again
plink \
    --vcf "$VCF" \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --indep-pairwise 100kb 1 0.1 \
    --make-bed \
    --threads 2 \
    --out "${WORK}/PDOM_auto_MAF05_LD100kb"

echo "SNPs before pruning:  $(wc -l < "${WORK}/PDOM_auto_MAF05_LD100kb.bim")"
echo "LD-pruned SNPs kept:  $(wc -l < "${WORK}/PDOM_auto_MAF05_LD100kb.prune.in")"
echo "SNPs removed by LD:   $(wc -l < "${WORK}/PDOM_auto_MAF05_LD100kb.prune.out")"
