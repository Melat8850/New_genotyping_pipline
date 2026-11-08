#!/bin/bash
#SBATCH --job-name=sfs_proj
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --time=12:00:00
#SBATCH --output=sfs_proj_%j.out
#SBATCH --error=sfs_proj_%j.err

set -euo pipefail
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS

EASYSFS=/cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/easySFS/easySFS.py
PY=/cluster/home/melatag/miniconda3/envs/easySFS_melat/bin/python

echo "Started: $(date)"

# projections: IND = 10, ZAF = 34
$PY $EASYSFS -i IND_ZAF_autosomes.vcf.gz -p pop_file -a -f \
    --proj 10,34 -o sfs_IND10_ZAF34

echo "Output files:"
find sfs_IND10_ZAF34 -type f | sort
echo "Finished: $(date)"
