#!/bin/bash
#
# Usage:
#   ./regtest.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

. util.sh

readonly THIS_DIR=$(dirname $0)
readonly REPO_ROOT=$THIS_DIR
readonly CLIENT_DIR=$REPO_ROOT/client/python
readonly REGTEST_DIR=_tmp/regtest

# All the Python tools need this
export PYTHONPATH=$CLIENT_DIR

# TODO: Get num cpus
readonly NUM_PROCS=12

run-all() {
  mkdir --verbose -p $REGTEST_DIR
  # Print the spec
  #
  # -n3 has to match the number of arguments in the spec.

  #local func=_run-one-case-logged
  local func=_run-one-case  # parallel process output mixed on the console

  tests/rappor_regtest.py \
    | xargs -n 12 -P $NUM_PROCS --verbose -- $0 $func

  which tree >/dev/null && tree $REGTEST_DIR

  # After these are done in parallel
  #
  # Output summary
  # Then cat _tmp/regtest/t*/metrics.csv
}

# Run a single test case, specified by a line of the test spec.
# This is a helper function for 'run-all'.

_run-one-case() {
  local test_case_id=$1
  local dist=$2
  local num_clients=$3
  local num_unique_values=$4

  local num_bits=$5
  local num_hashes=$6
  local num_cohorts=$7
  local p=$8
  local q=$9
  local f=${10}  # need curly braces to get 10th arg

  local num_additional=${11}
  local to_remove=${12}

  local case_dir=$REGTEST_DIR/$test_case_id
  mkdir --verbose -p $case_dir

  banner "Generating input"

  tests/gen_sim_input.py \
    -e \
    -n $num_clients \
    -r $num_unique_values \
    -o $case_dir/test.csv

  # NOTE: Have to name inputs and outputs by the test case name
  # _tmp/test/t1
  #./demo.sh gen-sim-input-demo $dist $num_clients $num_unique_values

  banner "Running RAPPOR"

  tests/rappor_sim.py \
    --bloombits $num_bits \
    --hashes $num_hashes \
    --cohorts $num_cohorts \
    -p $p \
    -q $q \
    -f $f \
    -i $case_dir/test.csv \
    -o $case_dir/out.csv

  banner "Deriving candidates from true inputs"

  # Reuse demo.sh function
  ./demo.sh print-candidates \
    $case_dir/test_true_inputs.txt $num_additional "$to_remove" \
    > $case_dir/test_candidates.txt

  banner "Hashing candidates"

  analysis/tools/hash_candidates.py \
    $case_dir/test_params.csv \
    < $case_dir/test_candidates.txt \
    > $case_dir/test_map.csv

  banner "Summing Bits"

  analysis/tools/sum_bits.py \
    $case_dir/test_params.csv \
    < $case_dir/out.csv \
    > $case_dir/counts.csv

  tests/analyze.R -h || true
  echo $?

  return

  # NOTE: This returns a prefix

  # reads input from params dir
  tests/analyze.R _tmp/$test_case_id _tmp/$test_case_id
}

# Like _run-once-case, but log to a file.
_run-one-case-logged() {
  local test_case_id=$1

  local case_dir=$REGTEST_DIR/$test_case_id
  mkdir --verbose -p $case_dir

  echo "Logging to $case_dir/log.txt"
  _run-one-case "$@" >$case_dir/log.txt 2>&1
}

h() {
  tests/rappor_sim.py -h || true
}

"$@"
