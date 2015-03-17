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
  <td>
  <td>
    %(spec)s
  <td>
  <td>
    %(metrics)s
  <td>
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

    data = {
        'name': spec_row[0],
        'spec': ' '.join(spec_row), 
        'metrics': ' '.join(metrics_row),
        }
    print ROW % data


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
