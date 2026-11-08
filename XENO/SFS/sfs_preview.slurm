#!/bin/bash
#SBATCH --job-name=sfs_preview
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G
#SBATCH --time=12:00:00
#SBATCH --output=sfs_preview_%j.out
#SBATCH --error=sfs_preview_%j.err

set -euo pipefail
cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS

EASYSFS=/cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/easySFS/easySFS.py
PY=/cluster/home/melatag/miniconda3/envs/easySFS_melat/bin/python

echo "Started: $(date)"
$PY $EASYSFS -i IND_ZAF_autosomes.vcf.gz -p pop_file -a -f --preview > preview.txt
echo "Preview written to preview.txt"
echo "Finished: $(date)"
