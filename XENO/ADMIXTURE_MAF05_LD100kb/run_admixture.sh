#!/bin/bash
#SBATCH --job-name=admixture
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=06:00:00

set -euo pipefail

# --------------------------------------------------
# USER DEFINITIONS
# --------------------------------------------------

WORKDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTURE_MAF05_LD100kb"

INPUT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PCA_MAF05/PCA_MAF05_LD100kb/MAF05_PCA"

INPUT_NAME="sparrows_MAF05_LD100kb_balanced"

K_MIN=2
K_MAX=5
CPUS_PER_TASK=1

# --------------------------------------------------
# LOAD MODULES
# --------------------------------------------------

module --quiet purge
module load PLINK/1.9b_6.13-x86_64
module load ADMIXTURE/1.3.0

module list

cd "$WORKDIR"

echo "=========================================="
echo "ADMIXTURE analysis"
echo "Started: $(date)"
echo "Working directory: $PWD"
echo "Input dataset: $INPUT"
echo "K values: $K_MIN to $K_MAX"
echo "=========================================="

plink \
    --chr-set 39 \
    --allow-extra-chr \
    --bfile "$INPUT" \
    --keep "$WORKDIR/keep_samples.txt" \
    --extract "$WORKDIR/autosomal_snps.txt" \
    --make-bed \
    --out "$WORKDIR/$INPUT_NAME"


# --------------------------------------------------
# STEP 2: PREPARE ADMIXTURE INPUT
# --------------------------------------------------

echo "Preparing ADMIXTURE input..."

mkdir -p admixture/.admixture_tmp

cp "$WORKDIR/$INPUT_NAME.bed" \
   "admixture/.admixture_tmp/$INPUT_NAME.admixture.bed"

cp "$WORKDIR/$INPUT_NAME.fam" \
   "admixture/.admixture_tmp/$INPUT_NAME.admixture.fam"

awk 'BEGIN {OFS="\t"} {$1="0"; print}' \
    "$WORKDIR/$INPUT_NAME.bim" \
    > "admixture/.admixture_tmp/$INPUT_NAME.admixture.bim"

# --------------------------------------------------
# STEP 3: RUN ADMIXTURE FOR K=2 TO K=5
# --------------------------------------------------

cd "$WORKDIR/admixture"

echo "Running ADMIXTURE..."
echo "Started: $(date)"

for K in $(seq "$K_MIN" "$K_MAX")
do
    echo "Running K=$K at $(date)"

    admixture \
        --cv \
        -j"$CPUS_PER_TASK" \
        ".admixture_tmp/$INPUT_NAME.admixture.bed" \
        "$K" \
        > "${INPUT_NAME}_K${K}.out"

    echo "Finished K=$K at $(date)"
done

# --------------------------------------------------
# STEP 4: COLLECT CROSS-VALIDATION RESULTS
# --------------------------------------------------

echo "Collecting cross-validation results..."

grep "CV error" "${INPUT_NAME}"_K*.out \
    > "${INPUT_NAME}.cv_summary.txt" || true

echo "Cross-validation summary:"
cat "${INPUT_NAME}.cv_summary.txt"

# --------------------------------------------------
# STEP 5: CLEAN UP TEMPORARY FILES
# --------------------------------------------------


echo "=========================================="
echo "ADMIXTURE analysis completed."
echo "Finished: $(date)"
echo "Results directory: $WORKDIR/admixture"
echo "=========================================="
