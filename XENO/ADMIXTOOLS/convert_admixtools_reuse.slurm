#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --job-name=admixtools_convert
#SBATCH --output=admixtools_convert_%j.out
#SBATCH --error=admixtools_convert_%j.err
#SBATCH --time=48:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=1

set -euo pipefail

module purge
module load AdmixTools/7.0.2-GCC-10.3.0
module load PLINK/1.9b_6.13-x86_64

WORKDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTOOLS"
cd "$WORKDIR"

IN=new_sparrow_autosomes.renamedScaff.vcf.gz
P=new_sparrow_autosomes.renamedScaff

echo "Started: $(date)"
test -s "$IN"
test -s convertVCFtoEigenstrat_plink.sh
command -v plink
command -v convertf

bash convertVCFtoEigenstrat_plink.sh "$IN"

ls -lh $P.eigenstratgeno $P.snp $P.ind
n=$(wc -l < $P.map); g=$(wc -l < $P.eigenstratgeno); s=$(wc -l < $P.snp); i=$(wc -l < $P.ind)
l1=$(head -n 1 $P.eigenstratgeno | tr -d '\n' | wc -c)
l2=$(tail -n 1 $P.eigenstratgeno | tr -d '\n' | wc -c)
echo "map=$n geno=$g snp=$s ind=$i first_line=$l1 last_line=$l2 (vcftools reported 30148239 sites)"
if [ "$g" -eq "$n" ] && [ "$s" -eq "$n" ] && [ "$i" -eq 162 ] && [ "$l1" -eq 162 ] && [ "$l2" -eq 162 ]; then
  echo "CHECKS PASSED"
else
  echo "ERROR: output has the wrong shape"; exit 1
fi
echo "Conversion finished: $(date)"
