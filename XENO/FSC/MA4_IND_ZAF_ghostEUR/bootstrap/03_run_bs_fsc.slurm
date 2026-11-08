#!/bin/bash
#SBATCH --job-name=bs_fsc
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-1000%200
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=12:00:00
#SBATCH --output=logs/fsc_%a_%A.out
#SBATCH --error=logs/fsc_%a_%A.err
set -euo pipefail

PREFIX=MA4_IND_ZAF_ghostEUR
FSC=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28
BS=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX/bootstrap

# task number → bootstrap (1–100) and run (1–10)
ID=$SLURM_ARRAY_TASK_ID
B=$(( (ID - 1) / 10 + 1 ))
R=$(( (ID - 1) % 10 + 1 ))
P=${PREFIX}.bs.${B}

mkdir -p $BS/bs$B/runs/run$R
cd $BS/bs$B/runs/run$R
cp $BS/bs$B/${P}.tpl $BS/bs$B/${P}.est $BS/bs$B/${P}_jointMAFpop1_0.obs ./
echo "bs$B run$R started: $(date)"
$FSC -t ${P}.tpl -e ${P}.est -m -0 -C 10 -n 100000 -L 40 -M -c 2 -q
echo "bs$B run$R finished: $(date)"
