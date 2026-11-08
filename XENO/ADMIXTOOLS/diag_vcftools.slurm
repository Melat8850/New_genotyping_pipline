#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --job-name=diag_vcftools
#SBATCH --output=vcftools_diag/diag_%j.out
#SBATCH --error=vcftools_diag/diag_%j.err
#SBATCH --time=04:00:00
#SBATCH --mem=24G
#SBATCH --cpus-per-task=1
set -euo pipefail
module purge
module load VCFtools/0.1.16-GCC-10.3.0
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTOOLS
vcftools --gzvcf new_sparrow_geno.renamedScaff.vcf.gz --plink --mac 1.0 --remove-indels --max-alleles 2 --out vcftools_diag/diag
head -n 2 vcftools_diag/diag.ped | awk '{print "line", NR, "fields:", NF}'
