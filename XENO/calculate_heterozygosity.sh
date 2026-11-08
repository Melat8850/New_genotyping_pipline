#!/bin/bash

#SBATCH --job-name=heterozygosity
#SBATCH --account=nn10082k
#SBATCH --time=04:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --array=0-13%3
#SBATCH --output=logs/heterozygosity/%A_%a.out
#SBATCH --error=logs/heterozygosity/%A_%a.err

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO

module purge

module load VCFtools/0.1.16-GCC-13.2.0

VCF=output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz

POPS=(CPV FRA GBR GMB IND IRN ITA KAZ KEN MDG NLD NOR SEN ZAF)

POP=${POPS[$SLURM_ARRAY_TASK_ID]}

echo "Calculating heterozygosity for $POP"

vcftools \
--gzvcf $VCF \
--keep FST_pairwise/population_lists/${POP}.txt \
--het \
--out output/heterozygosity/${POP}

echo "Finished $POP"
