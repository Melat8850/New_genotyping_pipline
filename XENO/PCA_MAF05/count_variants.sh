#!/bin/bash
#SBATCH --job-name=count_variants
#SBATCH --account=nn10082k
#SBATCH --time=01:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/count_variants_%j.out
#SBATCH --error=/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/count_variants_%j.err

set -euo pipefail

# Load BCFtools in a clean module environment
module --force purge
module load StdEnv
module load BCFtools/1.17-GCC-12.2.0

# Input VCF before MAF filtering
BEFORE="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# Input VCF after MAF filtering
AFTER="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/variants_default_filters_MAF05.vcf.gz"

# File to save the results
RESULT="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/PCA_MAF05/variant_counts.txt"

# Check that both VCFs and their indexes exist
for FILE in "$BEFORE" "$AFTER"; do
    if [[ ! -f "$FILE" ]]; then
        echo "ERROR: VCF not found: $FILE"
        exit 1
    fi

    if [[ ! -f "${FILE}.csi" && ! -f "${FILE}.tbi" ]]; then
        echo "ERROR: Index not found for: $FILE"
        exit 1
    fi
done

# Count variant records using the indexes
echo "Counting variant records..."
echo "Date: $(date)" > "$RESULT"

echo "Before MAF filtering:" >> "$RESULT"
bcftools index -n "$BEFORE" >> "$RESULT"

echo "After MAF filtering:" >> "$RESULT"
bcftools index -n "$AFTER" >> "$RESULT"

echo "Variant counts saved to: $RESULT"
cat "$RESULT"
