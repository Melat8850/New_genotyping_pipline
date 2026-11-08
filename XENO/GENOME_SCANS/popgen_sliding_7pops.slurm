#!/bin/bash
#SBATCH --job-name=popgen_sliding
#SBATCH --account=nn10082k
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --array=1-37
#SBATCH --output=logs_sliding_7pops/popgen_sliding_chr%a_%A.out

# Overlapping windows: 100 kb windows, 25 kb step

export PYTHONPATH=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/GENOME_SCANS/software/genomics_general
CHR=chr${SLURM_ARRAY_TASK_ID}

python3 software/genomics_general/popgenWindows.py \
   -g geno/${CHR}.geno.gz -o results_sliding_7pops/${CHR}.Fst.Dxy.pi.sliding.csv.gz \
   -f phased -w 100000 -m 5000 -s 25000 \
   -p KEN -p ZAF -p IND -p NOR -p FRA -p GBR -p NLD \
   --popsFile samples/pop_info.txt \
   -T 4
