#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:01:00
##SBATCH --mail-type=begin
##SBATCH --mail-type=end
##SBATCH --mail-type=fail
##SBATCH --mail-user=lmann@princeton.edu
cd /home/lmann/research_projects/hpc_adroit_demo
module load julia/1.7.1
srun -n 12 julia main.jl
