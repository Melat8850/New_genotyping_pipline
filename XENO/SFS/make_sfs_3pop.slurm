#!/bin/bash
#SBATCH --job-name=sfs_3pop
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=12:00:00
#SBATCH --output=sfs_3pop_%j.out
#SBATCH --error=sfs_3pop_%j.err

set -euo pipefail
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS

IN=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTOOLS/new_sparrow_autosomes.vcf.gz
EASYSFS=/cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/easySFS/easySFS.py
PY=/cluster/home/melatag/miniconda3/envs/easySFS_melat/bin/python

echo "Started: $(date)"

##############################################
# STEP 1. IND + ZAF + KEN, biallelic SNPs, variable, GT only
##############################################
module purge
module load BCFtools/1.23.1-GCC-15.2.0

bcftools view --threads 4 -S samples_IND_ZAF_KEN.txt -v snps -m2 -M2 $IN \
 | bcftools view --threads 4 -i 'MAC>=1' \
 | bcftools annotate --threads 4 -x INFO,^FORMAT/GT -Oz -o IND_ZAF_KEN_autosomes.vcf.gz
bcftools index IND_ZAF_KEN_autosomes.vcf.gz

echo "SNPs:        $(bcftools index -n IND_ZAF_KEN_autosomes.vcf.gz)"
echo "Samples:     $(bcftools query -l IND_ZAF_KEN_autosomes.vcf.gz | wc -l)"
echo "Chromosomes: $(bcftools index -s IND_ZAF_KEN_autosomes.vcf.gz | cut -f1 | paste -sd' ')"

##############################################
# STEP 2. easySFS preview (choose projections)
##############################################
module purge

$PY $EASYSFS -i IND_ZAF_KEN_autosomes.vcf.gz -p pop_file_3pop -a -f --preview > preview_3pop.txt
echo "Preview written to preview_3pop.txt"

echo "Finished: $(date)"
