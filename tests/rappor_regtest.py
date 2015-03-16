#!/usr/bin/python
"""
rappor_regtest.py
"""

import sys

# For gen_sim_input.py
INPUT_PARAMS = [
]

# For rappor_sim.py
RAPPOR_PARAMS = [
]

# Pairs of (input params, rappor params)

# should we have a name?
# or just identify by T1 .. Tn



TEST_CASES = [
]


def main(argv):
  # Construct test cases, then call
  # Put in env?
  #
  #
  # ./demo.sh run-all?
  # Should it be on stdin?

  # Should this just print the test spec to stdout?


  # Every line is an invocation of

  # ./demo.sh run-test-case "$@"

  # --out

  # analyze.R should write a CSV row in each dir
  #
  # _tmp/t1/metrics.csv
  #
  # And then you concatenate them all

  # Reuse:
  # - Reuse the same sim input
  # - Reuse the same map file - rappor library can cache it

  print r'10 10 10'
  print r'20 20 20'



if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
