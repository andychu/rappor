#!/bin/bash
#
# Usage:
#   ./regtest.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

readonly THIS_DIR=$(dirname $0)
readonly REPO_ROOT=$THIS_DIR
readonly CLIENT_DIR=$REPO_ROOT/client/python

# All the Python tools need this
export PYTHONPATH=$CLIENT_DIR


run-all() {
  # Print the spec
  #
  # -n3 has to match the number of arguments in the spec.
  tests/rappor_regtest.py \
    | xargs -n3 -P10 --verbose -- $0 _run-one-case

  # After these are done in parallel
  #
  # Then
}

# Private, don't rely on the arguments
_run-one-case() {
  local test_case_id=$1
  local num_clients=$2
  local num_unique_values=$3
  # ...

  echo "GOT $@"
  return

  tests/gen_sim_input.py -h || true

  tests/rappor_sim.py -h || true

  tests/analyze.R -h || true
  echo $?

  # reads input from params dir
  tests/analyze.R _tmp/$test_case_id _tmp/$test_case_id
}

"$@"
