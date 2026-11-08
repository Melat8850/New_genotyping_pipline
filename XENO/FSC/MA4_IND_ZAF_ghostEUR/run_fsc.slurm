#!/bin/bash
#SBATCH --job-name=fsc_MA4
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-100
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=12:00:00
#SBATCH --output=logs/run_%a_%A.out
#SBATCH --error=logs/run_%a_%A.err
set -euo pipefail
PREFIX=MA4_IND_ZAF_ghostEUR
FSC=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28
MODEL=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX
RUN=$SLURM_ARRAY_TASK_ID
mkdir -p $MODEL/runs/run$RUN
cd $MODEL/runs/run$RUN
cp $MODEL/${PREFIX}.tpl $MODEL/${PREFIX}.est $MODEL/${PREFIX}_jointMAFpop1_0.obs ./
echo "Run $RUN started: $(date)"
$FSC -t ${PREFIX}.tpl -e ${PREFIX}.est -m -0 -C 10 -n 100000 -L 40 -M -c 2 -q
echo "Run $RUN finished: $(date)"
