#!/bin/bash
#SBATCH --job-name=popgen
#SBATCH --account=nn10082k
#SBATCH --time=12:00:00
#SBATCH --mem=8G
#SBATCH --array=1-37
#SBATCH --output=logs/popgen_chr%a_%A.out

export PYTHONPATH=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
CHR=chr${SLURM_ARRAY_TASK_ID}

python3 software/genomics_general/popgenWindows.py \
   -g geno/${CHR}.geno.gz -o results/${CHR}.Fst.Dxy.pi.csv.gz \
   -f phased -w 100000 -m 5000 -s 100000 \
   -p KEN -p ZAF -p IND -p NOR -p FRA -p GBR -p NLD \
   --popsFile samples/pop_info.txt
