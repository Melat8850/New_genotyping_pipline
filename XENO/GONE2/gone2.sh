#!/bin/bash
#SBATCH --job-name=gone2
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=gone2_%x_%j.out
#SBATCH --error=gone2_%x_%j.err

set -e

##############################################
# SETTINGS
##############################################

POP=$1

VCF=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz
GONE2=/cluster/work/users/melatag/genotyping_pipeline/output/GONE/software/GONE2/gone2
OUTDIR=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GONE2/$POP
SAMPLES=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GONE2/samples/${POP}.txt

mkdir -p $OUTDIR
cd $OUTDIR

ulimit -s unlimited

##############################################
#  Make the input for this population
#   - only this population's birds
#   - autosomes >= 20 Mb (no Z, W, scaffolds)
#   - biallelic SNPs, variable, no missing genotypes
##############################################


module purge
module load BCFtools/1.23.1-GCC-15.2.0


CHR=$(bcftools view -h $VCF | grep "^##contig" \
      | sed -E 's/.*ID=([^,]+),length=([0-9]+).*/\1 \2/' \
      | awk '$1 ~ /^chr[0-9]+$/ && $2 >= 20000000 {print $1}' | paste -sd,)

if [ -z "$CHR" ]; then
    echo "ERROR: no chromosome lengths found in VCF header"; exit 1
fi
echo "Chromosomes kept (>= 20 Mb): $CHR"

bcftools view -S $SAMPLES -r $CHR -v snps -m2 -M2 $VCF \
  | bcftools view -i 'MAC>=1 && F_MISSING==0' -Oz -o ${POP}_GONE.vcf.gz

module purge
module load PLINK/1.9b_6.13-x86_64

plink \
    --vcf ${POP}_GONE.vcf.gz \
    --double-id \
    --allow-extra-chr \
    --chr-set 40 \
    --set-missing-var-ids @:# \
    --recode \
    --out ${POP}_GONE_final

sed -i 's/^chr//' ${POP}_GONE_final.map      # chr1 -> 1

echo "Number of SNPs after filtering:"
wc -l ${POP}_GONE_final.map

##############################################
# STEP 1. Create random subset of 2M SNPs
##############################################


shuf -n 2000000 --random-source=<(yes) ${POP}_GONE_final.map | cut -f2 > subset_2M.txt

echo "Number of selected SNPs:"
wc -l subset_2M.txt

##############################################
# STEP 2. Extract subset with PLINK
##############################################


plink \
    --file ${POP}_GONE_final \
    --extract subset_2M.txt \
    --allow-extra-chr \
    --chr-set 40 \
    --recode \
    --out ${POP}_2M


ls -lh ${POP}_2M.ped ${POP}_2M.map

echo "Number of SNPs in final dataset:"
wc -l ${POP}_2M.map

echo "Number of individuals:"
wc -l ${POP}_2M.ped

##############################################
# STEP 3. Run GONE2
##############################################


$GONE2 \
    -r 1 \
    -t 4 \
    -o ${POP}_GONE2_final \
    ${POP}_2M.ped
