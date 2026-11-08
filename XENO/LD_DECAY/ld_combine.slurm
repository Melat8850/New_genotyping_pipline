#!/bin/bash
#SBATCH --job-name=ld_combine
#SBATCH --account=nn10082k
#SBATCH --time=03:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --array=0-6
#SBATCH --output=logs/ld_combine_%a_%A.out

set -euo pipefail

PY=$HOME/miniconda3/bin/python3
POPS=(KEN ZAF IND NOR FRA GBR NLD)
POP=${POPS[$SLURM_ARRAY_TASK_ID]}
mkdir -p genome
echo "Combining ${POP} at $(date)"

# 1. join all 37 chromosomes: one header, chromosome column set to "genome"
{
  echo "CHR_A BP_A SNP_A CHR_B BP_B SNP_B R2"
  for i in $(seq 1 37); do
    zcat results/chr${i}/${POP}_chr${i}.ld.gz | tail -n +2
  done
} | awk 'NR==1 {print; next} {$1="genome"; $4="genome"; print}' \
  | gzip > genome/${POP}_genome.ld.gz

# 2. average r2 in 1 kb bins
${PY} scripts/ld_decay_calc_py3.py -i genome/${POP}_genome.ld.gz -o genome/${POP}_genome

echo "Finished ${POP} at $(date)"
