#!/bin/bash
#SBATCH --job-name=bs_sfs
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-100
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=logs/sfs_%a_%A.out
#SBATCH --error=logs/sfs_%a_%A.err
set -euo pipefail

PREFIX=MA4_IND_ZAF_ghostEUR
MODEL=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX
BS=$MODEL/bootstrap
POPFILE=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS/pop_file
PY=/cluster/home/melatag/miniconda3/envs/easySFS_melat/bin/python
EASYSFS=/cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/easySFS/easySFS.py
EASY_OPTS="-a -f --proj 10,34"     # must match your original SFS (check sfs_proj.slurm)

i=$SLURM_ARRAY_TASK_ID
mkdir -p $BS/bs$i
cd $BS/bs$i

# draw windows with replacement until the total SNP number reaches the observed total
awk -v seed=$i 'BEGIN{srand(seed)} {f[NR]=$1; n[NR]=$2; tot+=$2}
  END{ s=0; while (s < tot) { k=int(rand()*NR)+1; print f[k]; s+=n[k] } }' \
  ../window_counts.txt > windows_drawn.txt
echo "windows drawn: $(wc -l < windows_drawn.txt)"

# build the bootstrapped VCF: header + drawn windows
( cat ../header.vcf; cd ..; xargs cat < bs$i/windows_drawn.txt ) | gzip > bs$i.vcf.gz

# SFS from the bootstrapped VCF
$PY $EASYSFS -i bs$i.vcf.gz -p $POPFILE $EASY_OPTS -o sfs

# rename SFS + copy model files to match the bootstrap prefix
OBS=$(find sfs -name "*_jointMAFpop1_0.obs" | head -1)
cp $OBS ${PREFIX}.bs.${i}_jointMAFpop1_0.obs
cp $MODEL/${PREFIX}.tpl ${PREFIX}.bs.${i}.tpl
cp $MODEL/${PREFIX}.est ${PREFIX}.bs.${i}.est

rm bs$i.vcf.gz
echo "bs$i ready"
