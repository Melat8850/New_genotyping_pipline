#!/bin/bash
set -euo pipefail

OUTPUT="pairwise_weighted_fst.txt"
TEMP="${OUTPUT}.tmp"

printf "Population1\tPopulation2\tWeighted_FST\n" > "$TEMP"

for logfile in FST_*.err; do
    awk '
    /--out results\// {
        pair = $NF
        sub(/^.*\//, "", pair)
    }

    /Weir and Cockerham weighted Fst estimate:/ {
        value = $NF

        if (pair != "") {
            print pair "\t" value
            pair = ""
        }
    }
    ' "$logfile"
done | while IFS=$'\t' read -r pair value; do
    printf "%s\t%s\t%s\n" \
        "$(printf '%s' "$pair" | cut -d_ -f1)" \
        "$(printf '%s' "$pair" | cut -d_ -f2)" \
        "$value"
done >> "$TEMP"

mv "$TEMP" "$OUTPUT"

echo "Created $OUTPUT"
echo "Number of weighted FST estimates:"
awk 'NR > 1 {n++} END {print n+0}' "$OUTPUT"
