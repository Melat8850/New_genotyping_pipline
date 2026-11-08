#!/bin/bash
#SBATCH --job-name=bs3_fsc
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-10
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=12:00:00
#SBATCH --output=logs/3_fsc_%A_%a.out

PREFIX=MA4_IND_ZAF_ghostEUR
FSC=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28
BSDIR=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX/bootstrap

b=$1                          # bootstrap number (given when submitting)
run=$SLURM_ARRAY_TASK_ID      # run number 1-10
NAME=${PREFIX}.bs.${b}

# one folder per run
mkdir -p $BSDIR/bs$b/runs/run$run
cd $BSDIR/bs$b/runs/run$run

# copy the input files
cp $BSDIR/bs$b/${NAME}.tpl $BSDIR/bs$b/${NAME}.est $BSDIR/bs$b/${NAME}_jointMAFpop1_0.obs ./

# run fastsimcoal2
$FSC -t ${NAME}.tpl -e ${NAME}.est -m -0 -C 10 -n 100000 -L 40 -M -c 2 -q
