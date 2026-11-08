#!/bin/bash
#SBATCH --job-name=popgen_11pops
#SBATCH --account=nn10082k
#SBATCH --time=06:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-37
#SBATCH --output=logs_popgen_11pops/popgen_chr%a_%A.out

export PYTHONPATH=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
CHR=chr${SLURM_ARRAY_TASK_ID}

python3 software/genomics_general/popgenWindows.py \
   -g geno_all/${CHR}.geno.gz -o results_11pops/${CHR}.Fst.Dxy.pi.csv.gz \
   -f phased -w 100000 -m 5000 -s 100000 \
   -p KEN -p ZAF -p SEN -p GMB -p MDG -p CPV \
   -p IND -p NOR -p FRA -p GBR -p NLD \
   --popsFile samples/pop_info_all.txt \
   -T 8
