#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-100
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=06:00:00
#SBATCH --output=lhood_logs/%x_%a_%A.out
#SBATCH --error=lhood_logs/%x_%a_%A.err
set -euo pipefail

PREFIX=$1
FSC=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28
FSCDIR=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC
BEST=$FSCDIR/$PREFIX/runs/bestrun
REP=$FSCDIR/$PREFIX/lhood_dist/rep$SLURM_ARRAY_TASK_ID

mkdir -p $REP
cd $REP

# best parameters + observed SFS (renamed to match the maxL prefix, as in the tutorial)
cp $BEST/${PREFIX}_maxL.par ./
cp $BEST/${PREFIX}_jointMAFpop1_0.obs ./${PREFIX}_maxL_jointMAFpop1_0.obs

echo "Rep $SLURM_ARRAY_TASK_ID started: $(date)"
$FSC -i ${PREFIX}_maxL.par -n 1000000 -m -q -0 -c 2

# keep the likelihood values, delete the rest
sed -n '2,3p' ${PREFIX}_maxL/${PREFIX}_maxL.lhoods > lhood.txt
rm -r ${PREFIX}_maxL/
echo "Rep $SLURM_ARRAY_TASK_ID finished: $(date)"
