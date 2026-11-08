#!/bin/bash
#SBATCH --job-name=fd
#SBATCH --output=fd_%x_%j.out
#SBATCH --error=fd_%x_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=24:00:00
#SBATCH --account=nn10082k

set -e
set -u

AFR=$1      # P2: African population (ZAF or KEN)
EUR=$2      # P3: European donor (NOR, FRA, GBR or NLD)
WIN=$3      # window size: 10000 or 100000

echo "START: $(date)"

GG=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
export PYTHONPATH=${GG}:${PYTHONPATH:-}
PY=$HOME/miniconda3/bin/python3

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/fd

echo "Running fd analysis ($EUR introgression into $AFR, window $WIN)..."

${PY} ${GG}/ABBABABAwindows.py \
 -g chr8_fd.geno.gz \
 -f phased \
 -o fd_chr8_${EUR}_to_${AFR}_${WIN}.csv \
 -w $WIN \
 -s $WIN \
 -m 10 \
 -P1 IND \
 -P2 $AFR \
 -P3 $EUR \
 -O Outgroup \
 --popsFile pops_fd.txt \
 --minData 0.5 \
 -T 4

echo "END: $(date)"
