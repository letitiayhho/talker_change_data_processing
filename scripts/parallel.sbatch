#SBATCH --time=02:00:00
#SBATCH --partition=broadwl
#SBATCH --ntasks=28
#SBATCH --mem-per-cpu=2G  # NOTE DO NOT USE THE --mem= OPTION

# Load the default version of GNU parallel.
module load parallel

# When running a large number of tasks simultaneously, it may be
# necessary to increase the user process limit.
ulimit -u 10000

# This specifies the options used to run GNU parallel:
#
#   --delay of 0.2 prevents overloading the controlling node.
#
#   -j is the number of tasks run simultaneously.
#
#   The combination of --joblog and --resume create a task log that
#   can be used to monitor progress.
#
parallel="parallel --delay 0.2 -j $SLURM_NTASKS --joblog parallel.sbatch.log --resume"

# This specifies the options used to run srun.
srun="srun --exclusive -N4 -n1"

$parallel "srun --exclusive -N4 -n1 ./scripts/wrapper $SLURM_JOB_ID" -- $(seq 1 100)

tar cJvf output.tar.xz data/aggregate/*.mat data/logs
