#!/bin/bash
#SBATCH --job-name=bs1_blocks
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --mem=8G
#SBATCH --time=06:00:00
#SBATCH --output=logs/1_blocks_%j.out

# my input VCF
VCF=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS/IND_ZAF_autosomes.vcf.gz

# save the header separately
zgrep "^#" $VCF > header.vcf

# save all SNP lines (no header)
zgrep -v "^#" $VCF > allSites.txt

# cut into blocks of 11,909 SNPs (gives 1,000 blocks)
mkdir -p blocks
split -l 11909 -a 4 allSites.txt blocks/block_

# I don't need the big file anymore
rm allSites.txt

echo "number of blocks:"
ls blocks | wc -l
