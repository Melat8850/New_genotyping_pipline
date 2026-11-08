#!/bin/bash
#SBATCH --job-name=ld_r2
#SBATCH --account=nn10082k
#SBATCH --time=02:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=2
#SBATCH --array=1-37
#SBATCH --output=logs/ld_r2_chr%a_%A.out

set -euo pipefail
module purge
module load PLINK/1.9b_6.13-x86_64

CHR=chr${SLURM_ARRAY_TASK_ID}
POPS="KEN ZAF IND NOR FRA GBR NLD"
mkdir -p results/${CHR}

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
done

echo "Finished ${CHR} at $(date)"
