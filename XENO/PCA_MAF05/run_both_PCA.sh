#!/bin/bash
#SBATCH --job-name=sparrow_PCA
#SBATCH --account=nn10082k
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --output=sparrow_PCA_%j.out
#SBATCH --error=sparrow_PCA_%j.err

set -euo pipefail


module load PLINK/1.9b_6.13-x86_64

BASE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO"
WORK="${BASE}/PCA_MAF05"

VCF_MAF05="${BASE}/output/PCA_MAF05/variants_default_filters_MAF05.vcf.gz"
VCF_DEFAULT="${BASE}/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

REMOVE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/remove_samples_plink.txt"

PRUNE_MAF05="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/PCA_MAF05_LD100kb/MAF05_LD100kb.prune.in"
PRUNE_DEFAULT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/PCA_default_LD50kb/default_LD50kb.prune.in"




# PCA for MAF 0.05 dataset
plink \
  --vcf "$VCF_MAF05" \
  --double-id \
  --allow-extra-chr \
  --chr-set 40 \
  --set-missing-var-ids @:# \
  --remove "$REMOVE" \
  --extract "$PRUNE_MAF05" \
  --make-bed \
  --pca \
  --out /cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/PCA_MAF05_LD100kb/MAF05_PCA

# PCA for default-filtered dataset
plink \
  --vcf "$VCF_DEFAULT" \
  --double-id \
  --allow-extra-chr \
  --chr-set 40 \
  --set-missing-var-ids @:# \
  --remove "$REMOVE" \
  --extract "$PRUNE_DEFAULT" \
  --make-bed \
  --pca \
  --out /cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/PCA_default_LD50kb/default_PCA
