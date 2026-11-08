#!/bin/bash
#SBATCH --account=nn10082k
#SBATCH --output=FST_%j.out
#SBATCH --error=FST_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --job-name=pairwise_FST_resume
#SBATCH --time=24:00:00


set -euo pipefail


module purge
module load BCFtools/1.17-GCC-12.2.0
module load VCFtools/0.1.16-GCC-12.2.0

# Input VCF
VCF="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/output/03-variants_filtered/default_filters/variants_default_filters.vcf.gz"

# Output directory
OUTDIR="/cluster/work/users/melatag/new_genotyping_pipeline/XENO/FST_pairwise"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

# Extract sample IDs
bcftools query -l "$VCF" > samples_in_vcf.txt

# Create population lists
mkdir -p population_lists results

# Kenya
grep '^PDOM2011KEN' samples_in_vcf.txt > population_lists/KEN.txt

# United Kingdom
grep '^PDOM2012GBR' samples_in_vcf.txt > population_lists/GBR.txt

# France
grep '^PDOM2013FRA' samples_in_vcf.txt > population_lists/FRA.txt

# Cabo Verde
grep '^PDOM2014CPV' samples_in_vcf.txt > population_lists/CPV.txt

# Senegal
grep -E '^PDOM2015SEN|^PDOM2021SEN' samples_in_vcf.txt \
    | grep -v '^PDOM2021SEN0002U$' > population_lists/SEN.txt

# Madagascar
grep '^PDOM2018MDG' samples_in_vcf.txt > population_lists/MDG.txt

# Netherlands
grep '^PDOM2022NLD' samples_in_vcf.txt > population_lists/NLD.txt

# Gambia
grep '^PDOM2023GMB' samples_in_vcf.txt > population_lists/GMB.txt

# India
grep '^PDOM2023IND' samples_in_vcf.txt > population_lists/IND.txt

# Norway
grep '^PDOM2025NOR' samples_in_vcf.txt > population_lists/NOR.txt

# South Africa
grep '^PDOM2025ZAF' samples_in_vcf.txt > population_lists/ZAF.txt

# Italy
grep '^PHIS2008ITA' samples_in_vcf.txt > population_lists/ITA.txt

# Kazakhstan
grep '^PHIS2014KAZ' samples_in_vcf.txt > population_lists/KAZ.txt

# Iran
grep '^PPER2012IRN' samples_in_vcf.txt > population_lists/IRN.txt

# Check population sizes
echo "Population sample counts:"
for f in population_lists/*.txt; do
    printf "%s\t%s\n" "$(basename "$f" .txt)" "$(wc -l < "$f")"
done

# Check that all population lists contain samples
for f in population_lists/*.txt; do
    if [[ ! -s "$f" ]]; then
        echo "ERROR: Empty population list: $f"
        exit 1
    fi
done

# Calculate pairwise weighted FST
for pop1 in population_lists/*.txt; do
    name1=$(basename "$pop1" .txt)

    for pop2 in population_lists/*.txt; do
        name2=$(basename "$pop2" .txt)

        # Avoid comparing a population with itself and duplicate pairs
        [[ "$name1" < "$name2" ]] || continue

        # Skip existing results
        if [[ -s "results/${name1}_${name2}.weir.fst" ]]; then
            echo "Skipping existing result: ${name1} vs ${name2}"
            continue
        fi

        echo "Calculating FST: $name1 vs $name2"

        vcftools \
            --gzvcf "$VCF" \
            --weir-fst-pop "$pop1" \
            --weir-fst-pop "$pop2" \
            --out "results/${name1}_${name2}"

    done
done

echo "All pairwise FST calculations completed."
echo "Results are in: $OUTDIR/results"


^G Help          ^O Write Out     ^W Where Is	   ^K Cut           ^T Execute       ^C Location      M-U Undo         M-A Set Mark     M-] To Bracket   M-Q Previous     ^B Back          ^◀ Prev Word
^X Exit          ^R Read File     ^\ Replace	   ^U Pas
