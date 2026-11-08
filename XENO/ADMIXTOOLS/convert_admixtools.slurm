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
module load VCFtools/0.1.16-GCC-10.3.0

WORKDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/ADMIXTOOLS"
cd "$WORKDIR"

IN=new_sparrow_autosomes.vcf.gz

echo "Started: $(date)"
test -s "$IN"
test -s convertVCFtoEigenstrat.sh
command -v vcftools
command -v convertf

bash convertVCFtoEigenstrat.sh "$IN" --renameScaff

ls -lh new_sparrow_autosomes.{eigenstratgeno,snp,ind}
wc -l new_sparrow_autosomes.snp new_sparrow_autosomes.ind
echo "Conversion finished: $(date)"
