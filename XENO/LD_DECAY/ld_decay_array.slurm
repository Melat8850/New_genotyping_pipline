#!/bin/bash
#SBATCH --job-name=ld_decay
#SBATCH --account=nn10082k
#SBATCH --time=04:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=2
#SBATCH --array=1-37
#SBATCH --output=logs/ld_chr%a_%A.out

set -euo pipefail
module purge
module load PLINK/1.9b_6.13-x86_64
# ---- settings ----
FILT=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters
CHR=chr${SLURM_ARRAY_TASK_ID}
VCF=${FILT}/chroms/${CHR}/${CHR}_default_filters.vcf.gz
POPS="KEN ZAF IND NOR FRA GBR NLD"

mkdir -p tmp results/${CHR}
echo "Starting ${CHR} at $(date)"

# ---- 1. Convert this chromosome once: 70 birds, biallelic SNPs only ----
plink --vcf ${VCF} \
  --double-id --allow-extra-chr --chr-set 37 \
  --keep keep/all70_keep.txt \
  --snps-only just-acgt --biallelic-only strict \
  --set-missing-var-ids @:# \
  --threads 2 --memory 7000 \
  --make-bed --out tmp/${CHR}_70

# ---- 2. LD per population ----
for POP in ${POPS}; do
  echo "  ${POP} ${CHR}"

  plink --bfile tmp/${CHR}_70 \
    --chr-set 37 --allow-extra-chr \
    --keep keep/${POP}_keep.txt \
    --maf 0.05 --geno 0.1 --mind 0.5 \
    --thin 0.1 --seed 42 \
    --r2 gz --ld-window 999999 --ld-window-kb 200 --ld-window-r2 0 \
    --threads 2 --memory 7000 \
    --out results/${CHR}/${POP}_${CHR}


echo "Finished ${CHR} at $(date)"
