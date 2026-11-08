#!/bin/bash
#SBATCH --job-name=iqtree_var
#SBATCH --account=nn10082k
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=72:00:00
#SBATCH --output=iqtree_var_%j.out
#SBATCH --error=iqtree_var_%j.err

cd /cluster/work/users/melatag/new_genotyping_pipeline/XENO/PHYLOGENY/thin10kb

module --quiet purge
ml IQ-TREE/2.2.2.7-gompi-2023a

iqtree2 -st DNA -m GTR+ASC -B 1000 -T 12 --seed 47 \
    -o PMON2025NOR0001U,PMON2025NOR0002U,PMON2025NOR0003U,PMON2025NOR0004U,PMON2025NOR0005U,PMON2025NOR0006U,PMON2025NOR0007U,PMON2025NOR0008U,PMON2025NOR0009U,PMON2025NOR0010U \
    -s sparrows_thin10kb_resolved.min4.phy.varsites.phy
