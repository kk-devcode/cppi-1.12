## Process this file with automake to produce Makefile.in -*-Makefile-*-
TESTS = \
  version-check \
  d1 d2 d3 d4 d5 \
  e1 e2 e3 e4 e5 e6 e7 e8 e9 \
  f1 f2 f3 f4 f5    f7 f8 f9 \
  stringify-1 stringify-2 stringify-3 stringify-4 \
  8-bit ansi-1 ansi-2 ansi-3 ansi-4 ansi-5 ansi-6 ansi-7 ansi-8 \
  cxx-1 cxx-2 cxx-3

EXTRA_DIST = test-common $(TESTS)
TESTS_ENVIRONMENT = \
  srcdir=$(srcdir) \
  PACKAGE_VERSION=$(PACKAGE_VERSION) \
  PATH=../src$(PATH_SEPARATOR)$$PATH
