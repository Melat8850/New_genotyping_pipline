#!/bin/bash
#SBATCH --job-name=fd_geno_chr8
#SBATCH --account=nn10082k
#SBATCH --time=12:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/fd_geno_chr8_%j.out

set -euo pipefail
module purge
module load HTSlib/1.17-GCC-12.2.0          # for bgzip

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS

GG=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
export PYTHONPATH=${GG}:${PYTHONPATH:-}
PY=$HOME/miniconda3/bin/python3

SAMPLES=$(cut -f1 fd/pops_fd.txt | paste -sd,)    # IND, ZAF, KEN, 4 European pops + tree sparrows

echo "Start chr8 $(date)"

${PY} ${GG}/VCF_processing/parseVCF.py \
  -i vcf/chr8_allsites.vcf.gz \
  -s ${SAMPLES} \
  --skipIndels \
  | bgzip > fd/chr8_fd.geno.gz

echo "Samples in geno: $(zcat fd/chr8_fd.geno.gz | head -1 | tr '\t' '\n' | tail -n +3 | wc -l)"
echo "Finished chr8 $(date)"
