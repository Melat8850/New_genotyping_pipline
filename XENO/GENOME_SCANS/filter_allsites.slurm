#!/bin/bash
#SBATCH --job-name=filt_allsites
#SBATCH --account=nn10082k
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --array=1-37
#SBATCH --output=logs/filt_chr%a_%A.out

set -euo pipefail
module purge
module load VCFtools/0.1.16-GCC-12.2.0 BCFtools/1.17-GCC-12.2.0

CHR=chr${SLURM_ARRAY_TASK_ID}
IN=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/02-variants_unfiltered/chroms/${CHR}/${CHR}.vcf.gz
OUT=vcf/${CHR}

echo "Start ${CHR} $(date)"

# 1. invariant sites
vcftools --gzvcf ${IN} \
  --remove-indels --max-maf 0 \
  --max-missing 0.8 --minDP 5 --maxDP 30 --min-meanDP 5 --max-meanDP 30 \
  --recode --recode-INFO-all --stdout | bgzip -c > ${OUT}_invariant.vcf.gz

# 2. variant sites
vcftools --gzvcf ${IN} \
  --remove-indels --mac 1 --min-alleles 2 --max-alleles 2 --minQ 30 \
  --max-missing 0.8 --minDP 5 --maxDP 30 --min-meanDP 5 --max-meanDP 30 \
  --remove-filtered-all \
  --recode --recode-INFO-all --stdout | bgzip -c > ${OUT}_variant.vcf.gz

# 3. index both
tabix -p vcf ${OUT}_invariant.vcf.gz
tabix -p vcf ${OUT}_variant.vcf.gz

# 4. combine into one all-sites file
bcftools concat -a -Oz -o ${OUT}_allsites.vcf.gz ${OUT}_invariant.vcf.gz ${OUT}_variant.vcf.gz
tabix -p vcf ${OUT}_allsites.vcf.gz

echo "Finished ${CHR} $(date)"
