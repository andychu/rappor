#!/usr/bin/python
"""
rappor_regtest.py
"""

import sys

# For gen_sim_input.py
INPUT_PARAMS = {
    # distribution, num clients, num unique values
    # TODO: get rid of magic 7
    'e1': ('exp', 10000, 100),
    'e2': ('exp', 100000, 100),
    }

# For rappor_sim.py
RAPPOR_PARAMS = {
    # k,h,m,p,q,f
    'r1': (16, 2, 64, 0.5, 0.75, 0.5),
    }

MAP_PARAMS = {
    # Number of fake candidates to add.  Candidate strings to remove from the
    # map.
    # The number of maps.
    'm1': (10, []),
    'm2': (10, ['v1', 'v2']),
    'm3': (50, ['v1', 'v2']),
    }

# Pairs of (input params, rappor params)

# should we have a name?
# or just identify by T1 .. Tn

TEST_CASES = {
    # same parameters as the demo
    'demo': ('e1', 'r1', 'm1'),
    'chrome': ('e2', 'r1', 'm2'),
    }


def main(argv):
  # analyze.R should write a CSV row in each dir
  #
  # _tmp/t1/metrics.csv
  #
  # And then you concatenate them all

  # Reuse:
  # - Reuse the same sim input
  # - Reuse the same map file - rappor library can cache it

  rows = []
  for test_case, (input_name, rappor_name, map_name) in TEST_CASES.iteritems():
    input_params = INPUT_PARAMS[input_name]
    rappor_params = RAPPOR_PARAMS[rappor_name]
    map_params = MAP_PARAMS[map_name]
    #print input_params, rappor_params
    row = tuple([test_case,]) + input_params + rappor_params + map_params
    rows.append(row)

  for row in rows:
    for cell in row:
      if isinstance(cell, list):
        if cell:
          cell_str = '|'.join(cell)
        else:
          cell_str = '-'  # we don't want an empty string
      else:
        cell_str = cell
      print cell_str,  # print it with a space after it
    print  # new line after row


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
