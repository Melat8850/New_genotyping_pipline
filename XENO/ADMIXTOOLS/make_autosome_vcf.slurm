#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --job-name=autosome_vcf
#SBATCH --output=autosome_vcf_%j.out
#SBATCH --error=autosome_vcf_%j.err
#SBATCH --time=06:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
set -euo pipefail
module purge
module load BCFtools/1.23.1-GCC-15.2.0
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTOOLS
echo "Started: $(date)"
zcat new_sparrow_geno.vcf.gz \
 | awk '/^#/{print; next} $1 ~ /^chr[0-9]+$/{print; a++; next} $1=="chrZ"{z++; next} {o++} END{printf "autosomal=%d chrZ=%d other=%d total=%d\n", a,z,o,a+z+o > "/dev/stderr"}' \
 | bcftools view --threads 2 -Oz -o new_sparrow_autosomes.vcf.gz -
ls -lh new_sparrow_autosomes.vcf.gz
echo "Finished: $(date)"
