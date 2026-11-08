#!/bin/bash
#SBATCH --job-name=bs_windows
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=06:00:00
#SBATCH --output=logs/windows_%j.out
#SBATCH --error=logs/windows_%j.err
set -euo pipefail
module load BCFtools

VCF=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS/IND_ZAF_autosomes.vcf.gz
BS=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/MA4_IND_ZAF_ghostEUR/bootstrap
cd $BS
mkdir -p windows

# keep only genotypes (GT) to make files small
bcftools annotate -x ^FORMAT/GT $VCF -Oz -o gt_only.vcf.gz
bcftools view -h gt_only.vcf.gz > header.vcf

# one file per 1 Mb window: name = chromosome_windownumber
bcftools view -H gt_only.vcf.gz | awk -F'\t' '{
  w = $1 "_" int($2/1000000)
  if (w != prev) { if (prev != "") close(f); f = "windows/" w ".txt"; prev = w }
  print > f
}'

# SNP count per window (used to match the observed SFS size)
for f in windows/*.txt; do echo -e "$f\t$(wc -l < $f)"; done > window_counts.txt
echo "windows: $(wc -l < window_counts.txt)"
echo "total SNPs: $(awk '{s+=$2} END{print s}' window_counts.txt)"
