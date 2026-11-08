#!/bin/bash
#SBATCH --job-name=tree_thin
#SBATCH --account=nn10082k
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=72:00:00
#SBATCH --output=tree_thin_%j.out
#SBATCH --error=tree_thin_%j.err

set -euo pipefail

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY

# input VCF (default filters, no MAF filter)
VCF=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz

# one tree sparrow sample to root the tree (change this)
OUTGROUP=PMON_SAMPLE_NAME

mkdir -p thin10kb


# 1. Thin the SNPs: keep only autosomes, sites with <10% missing data,
#    and at most one SNP every 10 kb
module purge
module load VCFtools/0.1.16-GCC-12.2.0

vcftools --gzvcf $VCF \
    --remove remove_SEN.txt \
    --chr chr1 --chr chr2 --chr chr3 --chr chr4 --chr chr5 \
    --chr chr6 --chr chr7 --chr chr8 --chr chr9 --chr chr10 \
    --chr chr11 --chr chr12 --chr chr13 --chr chr14 --chr chr15 \
    --chr chr16 --chr chr17 --chr chr18 --chr chr19 --chr chr20 \
    --chr chr21 --chr chr22 --chr chr23 --chr chr24 --chr chr25 \
    --chr chr26 --chr chr27 --chr chr28 --chr chr29 --chr chr30 \
    --chr chr31 --chr chr32 --chr chr33 --chr chr34 --chr chr35 \
    --chr chr36 --chr chr37 \
    --max-missing 0.9 \
    --mac 1 \
    --thin 10000 \
    --recode --stdout | gzip > thin10kb/sparrows_thin10kb.vcf.gz

echo "SNPs after thinning:"
zcat thin10kb/sparrows_thin10kb.vcf.gz | grep -vc "^#"


# 2. Convert the VCF to PHYLIP for IQ-TREE
module purge
module load Python/3.12.3-GCCcore-13.3.0

python vcf2phylip.py -i thin10kb/sparrows_thin10kb.vcf.gz \
    --output-folder thin10kb \
    --output-prefix sparrows_thin10kb


# 3. Build the tree
#    GTR+ASC because the alignment only has variable sites
#    -B 1000 = ultrafast bootstrap, -alrt 1000 = SH-aLRT support
module purge
module load IQ-TREE/2.4.0-gompi-2024a

iqtree2 -s thin10kb/sparrows_thin10kb.min4.phy \
    -m GTR+ASC \
    -B 1000 \
    -o $OUTGROUP \
    -T 12 --seed 47 \
    --prefix thin10kb/sparrows_thin10kb_tree
