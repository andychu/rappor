#!/usr/bin/python
"""
rappor_regtest.py
"""

import sys

# For gen_sim_input.py
INPUT_PARAMS = {
    'e1': ('exp', 10000, 100),
    'e2': ('exp', 100000, 100),
    }

# For rappor_sim.py
RAPPOR_PARAMS = {
    # k,h,m,p,q,f
    'r1': (16, 2, 64, 0.5, 0.75, 0.5),
    }

# Pairs of (input params, rappor params)

# should we have a name?
# or just identify by T1 .. Tn

TEST_CASES = {
    # same parameters as the demo
    'demo': ('e1', 'r1'),
    'chrome': ('e2', 'r1'),
    }


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

  rows = []
  for test_case, (input_name, rappor_name) in TEST_CASES.iteritems():
    input_params = INPUT_PARAMS[input_name]
    rappor_params = RAPPOR_PARAMS[rappor_name]
    #print input_params, rappor_params
    row = tuple([test_case,]) + input_params + rappor_params
    rows.append(row)

  for row in rows:
    for cell in row:
      print cell,  # print it with a space after it
    print  # new line after row


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
