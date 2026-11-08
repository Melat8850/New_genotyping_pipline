#!/bin/bash
#SBATCH --job-name=fsc_MA
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-50
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=12:00:00
#SBATCH --output=logs/run_%a_%A.out
#SBATCH --error=logs/run_%a_%A.err

set -euo pipefail

##############################################
# SETTINGS
##############################################

PREFIX=MA_IND_ZAF_isolation
FSC=/cluster/work/users/melatag/software/fastsimcoal2/fsc28_linux64/fsc28
MODEL=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX

RUN=$SLURM_ARRAY_TASK_ID      # run number 1 ... 50

##############################################
# Make a separate folder for this run
##############################################

mkdir -p $MODEL/runs/run$RUN
cd $MODEL/runs/run$RUN

# copy the model, parameter and SFS files into the run folder
cp $MODEL/${PREFIX}.tpl $MODEL/${PREFIX}.est $MODEL/${PREFIX}_jointMAFpop1_0.obs ./

##############################################
# Run fastsimcoal2
#  -m       folded SFS (MAF)
#  -0       ignore monomorphic sites
#  -C 10    pool SFS cells with < 10 SNPs
#  -n       100,000 simulations per likelihood
#  -L 40    40 optimisation (ECM) cycles
#  -M       estimate parameters
#  -c 2     use 2 CPUs
#  -q       quiet output
##############################################

echo "Run $RUN started: $(date)"

$FSC -t ${PREFIX}.tpl -e ${PREFIX}.est -m -0 -C 10 -n 100000 -L 40 -M -c 2 -q

echo "Run $RUN finished: $(date)"
