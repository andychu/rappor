#!/usr/bin/python
"""
make_summary.py
"""

import os
import sys

# See matching header in tests/regtest.html.

ROW = """\
<tr>
  <td>
    %(name)s
  </td>
  <td>
    %(input)s
  </td>
  <td>
    %(rappor)s
  </td>
  <td>
    %(map)s
  </td>
  <td>
    %(metrics)s
  </td>
</tr>
"""

def main(argv):
  base_dir = argv[1]

  # This file has the test case names, in the order that they should be
  # displayed.
  path = os.path.join(base_dir, 'test-cases.txt')
  with open(path) as f:
    test_cases = [line.strip() for line in f]

  for case in test_cases:
    spec = os.path.join(base_dir, case, 'spec.txt')
    with open(spec) as s:
      spec_row = s.readline().split()

    #print spec_row

    metrics = os.path.join(base_dir, case + '_report', 'metrics.csv')
    with open(metrics) as m:
      header = m.readline()
      #print header
      metrics_row = m.readline().split(',')

    #print metrics_row

    def Piece(s, begin, end):
      return ' '.join(s[begin : end])

    data = {
        # See tests/regtest_spec.py for the definition of the spec row
        'name': spec_row[0],
        'input': Piece(spec_row, 1, 5),
        'rappor': Piece(spec_row, 5, 11),
        'map': Piece(spec_row, 11, 13),
        'metrics': ' '.join(metrics_row),
        }
    print ROW % data


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
