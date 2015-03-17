#!/usr/bin/python
"""
make_summary.py
"""

import sys


def main(argv):
  pairs = argv[1:]
  pairs.sort()
  # Now it looks like t1/spec.txt, t1_report/metrics.csv, t2/spec.txt,
  # t2_report/metrics.csv, ...
  assert len(pairs) % 2 == 0

  for i in xrange(len(pairs) / 2):
    spec = pairs[i*2]
    metrics = pairs[i*2 + 1]

    with open(spec) as s:
      with open(metrics) as m:
        print s.read()
        print m.read()


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
