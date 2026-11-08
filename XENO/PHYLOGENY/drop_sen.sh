#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --job-name=drop_sen
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=03:00:00
set -euo pipefail
module --quiet purge
module load BCFtools/1.23.1-GCC-15.2.0
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO
IN=output/PCA_MAF05/variants_default_filters_MAF05.vcf.gz
OUT=PHYLOGENY/filtered/MAF05_noSEN.vcf.gz
test -s "$IN"
bcftools view -s ^PDOM2021SEN0002U --threads 2 -Oz -o "$OUT" "$IN"
bcftools index --threads 2 "$OUT"
echo "Samples: $(bcftools query -l "$OUT" | wc -l)"
echo "Sites: $(bcftools index -n "$OUT")"
