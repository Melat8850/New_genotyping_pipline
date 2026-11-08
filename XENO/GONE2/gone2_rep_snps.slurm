#!/bin/bash
#SBATCH --job-name=gone2_rep
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-50
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=gone2_rep_%x_%a_%A.out
#SBATCH --error=gone2_rep_%x_%a_%A.err

set -e

##############################################
# SETTINGS
##############################################

POP=$1                     # population, e.g. ZAF
NSUB=${2:-2000000}         # SNPs per subset (default 2,000,000)
RATE=1                     # recombination rate (cM/Mb), same as main run

GONE2=/cluster/work/users/melatag/genotyping_pipeline/output/GONE/software/GONE2/gone2
DIR=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GONE2/$POP
REP=$SLURM_ARRAY_TASK_ID   # replicate number 1 ... 50

cd $DIR
mkdir -p snpslist replicates
ulimit -s unlimited

##############################################
# STEP 1. List of all filtered SNPs
##############################################

cut -f2 ${POP}_GONE_final.map > snpslist/${POP}_all_rep${REP}.snps
echo "$POP: $(wc -l < snpslist/${POP}_all_rep${REP}.snps) SNPs in total"

##############################################
# STEP 2. Random subset of SNPs (without replacement)
##############################################

shuf -n $NSUB snpslist/${POP}_all_rep${REP}.snps | sort > snpslist/subset_${NSUB}_${REP}.snps
rm snpslist/${POP}_all_rep${REP}.snps
echo "Replicate $REP: $(wc -l < snpslist/subset_${NSUB}_${REP}.snps) SNPs selected"

##############################################
# STEP 3. Make ped/map for this subset
##############################################

module purge
module load PLINK/1.9b_6.13-x86_64

plink \
    --file ${POP}_GONE_final \
    --extract snpslist/subset_${NSUB}_${REP}.snps \
    --allow-extra-chr \
    --chr-set 40 \
    --recode \
    --out replicates/${POP}_sub${NSUB}_rep${REP}

##############################################
# STEP 4. Run GONE2
##############################################

$GONE2 \
    -r $RATE \
    -t 4 \
    -o replicates/${POP}_sub${NSUB}_rep${REP} \
    replicates/${POP}_sub${NSUB}_rep${REP}.ped

# remove the large subset ped/map to save space (GONE2 results are kept)
rm replicates/${POP}_sub${NSUB}_rep${REP}.{ped,map,log,nosex}

echo "Finished $POP replicate $REP: $(date)"
