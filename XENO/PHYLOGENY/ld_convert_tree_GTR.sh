#!/bin/bash
#SBATCH --job-name=ld_convert_tree
#SBATCH --output=SLURM-%j-%x.out
#SBATCH --error=SLURM-%j-%x.err
#SBATCH --account=nn10082k
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=72:00:00

set -euo pipefail

# ---------- Paths ----------
WORK="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY"
VCF="${WORK}/filtered/MAF05_noSEN.vcf.gz"
OUT="${WORK}/ld_convert_tree_out"
mkdir -p "${OUT}/ld" "${OUT}/phylip" "${OUT}/tree"
cd "$WORK"
test -s "$VCF"
test -s vcf2phylip.py
echo "Started: $(date)"

# ---------- STEP 1: LD pruning  ----------
module --quiet purge
module load PLINK/1.9b_6.13-x86_64

plink \
    --vcf "$VCF" \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --indep-pairwise 50kb 10 0.1 \
    --memory 40000 \
    --out "${OUT}/ld/LD50kb"

echo "SNPs retained: $(wc -l < ${OUT}/ld/LD50kb.prune.in)"
echo "SNPs excluded: $(wc -l < ${OUT}/ld/LD50kb.prune.out)"
test "$(wc -l < ${OUT}/ld/LD50kb.prune.in)" -gt 1000

# keep only the retained SNPs and write them as a VCF
plink \
    --vcf "$VCF" \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --extract "${OUT}/ld/LD50kb.prune.in" \
    --recode vcf-iid bgz \
    --memory 40000 \
    --out "${OUT}/ld/LD50kb_pruned"
test -s "${OUT}/ld/LD50kb_pruned.vcf.gz"

# ---------- STEP 2: conversion to PHYLIP (settings from convert_tree.sh) ----------
module --quiet purge
module load Python/3.12.3-GCCcore-13.3.0

python vcf2phylip.py \
    -i "${OUT}/ld/LD50kb_pruned.vcf.gz" \
    --output-folder "${OUT}/phylip" \
    --output-prefix house_sparrow_LD50kb_pruned

PHY=$(ls ${OUT}/phylip/house_sparrow_LD50kb_pruned*.phy | head -n 1)
echo "Alignment: $PHY"
head -n 1 "$PHY"

# ---------- STEP 3: tree building ----------
module --quiet purge
module load IQ-TREE/2.4.0-gompi-2024a

iqtree2 \
    -s "$PHY" \
    -st DNA \
    -m GTR \
    -B 1000 \
    -T 12 \
    --seed 47 \
    --prefix "${OUT}/tree/house_sparrow_LD50kb_tree"

echo "Finished: $(date)"
