#!/usr/bin/python
"""Print a test spec on stdout.

Each line has parmaeters for a test case.  The regtest.sh shell script reads
these lines and runs parallel processes.

We use Python data structures so the test cases are easier to read and edit.
"""

import sys

#
# TEST CONFIGURATION
#

# For gen_sim_input.py
INPUT_PARAMS = {
    # distribution, num clients, num unique values
    # TODO: get rid of magic 7
    'e1': ('exp', 10000, 100),
    'e2': ('exp', 100000, 100),
    }

# For rappor_sim.py
RAPPOR_PARAMS = {
    # 'k, h, m, p, q, f' as in params file.
    'r1': (16, 2, 64, 0.5, 0.75, 0.5),
    }

# For deriving candidates from true inputs.
MAP_PARAMS = {
    # 1. Number of extra candidates to add.
    # 2. Candidate strings to remove from the map.  This FORCES false
    # negatives, e.g. for common strings, since a string has to be in the map
    # for RAPPOR to choose it.
    'm1': (10, []),
    'm2': (10, ['v1', 'v2']),
    'm3': (50, ['v1', 'v2']),
    }

# test case name -> (input params name, RAPPOR params name, map params name)
TEST_CASES = {
    # same parameters as the demo
    'demo': ('e1', 'r1', 'm1'),
    'chrome': ('e1', 'r1', 'm2'),
    }

#
# END TEST CONFIGURATION
#


def main(argv):
  rows = []
  for test_case, (input_name, rappor_name, map_name) in TEST_CASES.iteritems():
    input_params = INPUT_PARAMS[input_name]
    rappor_params = RAPPOR_PARAMS[rappor_name]
    map_params = MAP_PARAMS[map_name]
    row = tuple([test_case,]) + input_params + rappor_params + map_params
    rows.append(row)

  for row in rows:
    for cell in row:
      if isinstance(cell, list):
        if cell:
          cell_str = '|'.join(cell)
        else:
          cell_str = 'NONE'  # we don't want an empty string
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
