#!/bin/bash
#
# Run end-to-end tests in parallel.
#
# Usage:
#   ./regtest.sh <function name>

# Examples:
#
# $ export NUM_PROCS=20  # 12 by default
# $ ./regtest.sh run-all  # run all reg tests
#
# There will be CSV output.

# Flow:
#
# analyze.R should write a CSV row in each dir
#
# _tmp/t1/metrics.csv
#
# And then you concatenate them all

# TODO:
# - Reuse the same sim input -- come up with naming scheme
# - Reuse the same map file -- ditto, rappor library can cache it

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
readonly NUM_PROCS=${NUM_PROCS:-12}

run-all() {
  # Limit it to this number of test cases.  By default we run all of them.
  local max_cases=${1:-1000000}

  mkdir --verbose -p $REGTEST_DIR
  # Print the spec
  #
  # -n3 has to match the number of arguments in the spec.

  #local func=_run-one-case-logged
  local func=_run-one-case  # parallel process output mixed on the console

  tests/regtest_spec.py \
    | head -n $max_cases \
    | xargs -n 12 -P $NUM_PROCS --verbose -- $0 $func

  which tree >/dev/null && tree $REGTEST_DIR

  # Now
  head $REGTEST_DIR/*_report/metrics.csv
}

# Run a single test case, specified by a line of the test spec.
# This is a helper function for 'run-all'.

_run-one-case() {
  local test_case_id=$1

  # input params
  local dist=$2
  local num_clients=$3
  local num_unique_values=$4

  # RAPPOR params
  local num_bits=$5
  local num_hashes=$6
  local num_cohorts=$7
  local p=$8
  local q=$9
  local f=${10}  # need curly braces to get 10th arg

  # map params
  local num_additional=${11}
  local to_remove=${12}

  local case_dir=$REGTEST_DIR/$test_case_id
  mkdir --verbose -p $case_dir

  banner "Generating input"

  tests/gen_sim_input.py \
    -e \
    -n $num_clients \
    -r $num_unique_values \
    -o $case_dir/case.csv

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
    -i $case_dir/case.csv \
    -o $case_dir/out.csv

  banner "Deriving candidates from true inputs"

  # Reuse demo.sh function
  ./demo.sh print-candidates \
    $case_dir/case_true_inputs.txt $num_additional "$to_remove" \
    > $case_dir/case_candidates.txt

  banner "Hashing candidates"

  analysis/tools/hash_candidates.py \
    $case_dir/case_params.csv \
    < $case_dir/case_candidates.txt \
    > $case_dir/case_map.csv

  banner "Summing Bits"

  analysis/tools/sum_bits.py \
    $case_dir/case_params.csv \
    < $case_dir/out.csv \
    > $case_dir/case_counts.csv

  local out_dir=$REGTEST_DIR/${test_case_id}_report
  mkdir --verbose -p $out_dir

  # Input prefix, output dir
  tests/analyze.R -t "Test case: $test_case_id" "$case_dir/case" $out_dir
}

# Like _run-once-case, but log to a file.
_run-one-case-logged() {
  local test_case_id=$1

  local case_dir=$REGTEST_DIR/$test_case_id
  mkdir --verbose -p $case_dir

  echo "Logging to $case_dir/log.txt"
  _run-one-case "$@" >$case_dir/log.txt 2>&1
}

show-help() {
  tests/gen_sim_input.py || true
  tests/rappor_sim.py -h || true
}

"$@"
