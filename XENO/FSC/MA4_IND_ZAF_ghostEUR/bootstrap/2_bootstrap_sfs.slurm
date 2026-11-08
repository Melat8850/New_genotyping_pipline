#!/bin/bash
#SBATCH --job-name=bs2_sfs
#SBATCH --account=nn10082k
#SBATCH --partition=normal
#SBATCH --array=1-100
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=logs/2_sfs_%a.out

PREFIX=MA4_IND_ZAF_ghostEUR
MODEL=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FSC/$PREFIX
POPFILE=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/SFS/pop_file
PYTHON=/cluster/home/melatag/miniconda3/envs/easySFS_melat/bin/python
EASYSFS=/cluster/work/users/melatag/genotyping_pipeline/output/fastsimcoal2/sfs_easysfs_test/easySFS/easySFS.py

i=$SLURM_ARRAY_TASK_ID

# one folder per bootstrap
mkdir -p bs$i
cd bs$i

# start the new VCF with the header
cat ../header.vcf > bs$i.vcf

# add 1000 random blocks (some can be picked twice)
for r in {1..1000}
do
  cat $(shuf -n1 -e ../blocks/block_*) >> bs$i.vcf
done

# compress it
gzip bs$i.vcf

# make the SFS (same settings as my original SFS)
$PYTHON $EASYSFS -i bs$i.vcf.gz -p $POPFILE -a -f --proj 10,34 -o sfs

# copy the SFS and model files with matching names
cp sfs/fastsimcoal2/*_jointMAFpop1_0.obs ${PREFIX}.bs.${i}_jointMAFpop1_0.obs
cp $MODEL/${PREFIX}.tpl ${PREFIX}.bs.${i}.tpl
cp $MODEL/${PREFIX}.est ${PREFIX}.bs.${i}.est

# delete the big VCF to save space
rm bs$i.vcf.gz

echo "bs$i ready"
