#!/bin/bash
#SBATCH --job-name=sparrow_PCA_auto
#SBATCH --account=nn10082k
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --output=sparrow_PCA_auto_%j.out
#SBATCH --error=sparrow_PCA_auto_%j.err

set -euo pipefail

module load PLINK/1.9b_6.13-x86_64

WORK="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_auto_MAF05_LD100kb"

# NEW: read the binary files from script 2 (much faster than the VCF)
BFILE="${WORK}/PDOM_auto_MAF05_LD100kb"
PRUNE="${WORK}/PDOM_auto_MAF05_LD100kb.prune.in"

test -f "${BFILE}.bed"
test -f "$PRUNE"

# PCA on LD-pruned SNPs; --make-bed gives the pruned dataset (reuse for ADMIXTURE)
plink \
  --bfile "$BFILE" \
  --allow-extra-chr \
  --chr-set 40 \
  --extract "$PRUNE" \
  --make-bed \
  --pca 20 \
  --threads 2 \
  --out "${WORK}/PDOM_auto_MAF05_LD100kb_PCA"

echo "Samples in PCA:  $(wc -l < "${WORK}/PDOM_auto_MAF05_LD100kb_PCA.fam")"
echo "SNPs in PCA:     $(wc -l < "${WORK}/PDOM_auto_MAF05_LD100kb_PCA.bim")"
echo "Variance explained (% of top 20 PCs):"
awk '{v[NR]=$1; s+=$1} END {for (i=1;i<=NR;i++) printf "PC%d\t%.2f%%\n", i, 100*v[i]/s}' \
    "${WORK}/PDOM_auto_MAF05_LD100kb_PCA.eigenval"
