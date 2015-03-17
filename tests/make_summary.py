#!/usr/bin/python
"""
make_summary.py
"""

import os
import sys


def main(argv):
  base_dir = argv[1]
  path = os.path.join(base_dir, 'test-cases.txt')
  with open(path) as f:
    for line in f:
      print line


if __name__ == '__main__':
  try:
    main(sys.argv)
  except RuntimeError, e:
    print >>sys.stderr, 'FATAL: %s' % e
    sys.exit(1)
