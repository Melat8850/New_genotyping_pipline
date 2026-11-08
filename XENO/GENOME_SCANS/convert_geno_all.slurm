#!/bin/bash
#SBATCH --job-name=vcf2geno_all
#SBATCH --account=nn10082k
#SBATCH --time=12:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --array=1-37
#SBATCH --output=logs_geno_all/geno_chr%a_%A.out

set -euo pipefail
module purge
module load HTSlib/1.17-GCC-12.2.0          # for bgzip

GG=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
export PYTHONPATH=${GG}:${PYTHONPATH:-}
PY=python3

CHR=chr${SLURM_ARRAY_TASK_ID}
SAMPLES=$(paste -sd, samples/keep_samples_all.txt)     # 97 birds, comma-separated

echo "Start ${CHR} $(date)"

${PY} ${GG}/VCF_processing/parseVCF.py \
  -i vcf/${CHR}_allsites.vcf.gz \
  -s ${SAMPLES} \
  --skipIndels \
  | bgzip > geno_all/${CHR}.geno.gz

echo "Finished ${CHR} $(date)"
