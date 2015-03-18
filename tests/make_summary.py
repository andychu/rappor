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
    <a href="#%(name)s">%(name)s</a>
  </td>
  %(cell_html)s
</tr>
"""

DETAILS = """\
<p style="text-align: right">
  <a href="#top">Up</a>
</p>

<a id="%(name)s"></a>
<p style="text-align: center">
  <img src="%(name)s_report/dist.png" />
</p>
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

    row = spec_row[1:13] + metrics_row
    cell_html = ' '.join('<td>%s</td>' % cell for cell in row)

    data = {
        # See tests/regtest_spec.py for the definition of the spec row
        'name': case,
        'cell_html': cell_html,
        }
    print ROW % data

  print '</tbody>'
  print '</table>'
  print '<hr />'

  # Plot links.
  # TODO: Repeat params?
  for case in test_cases:
    print DETAILS % {'name': case}


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
