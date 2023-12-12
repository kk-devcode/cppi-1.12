## Process this file with automake to produce Makefile.in.

AUTOMAKE_OPTIONS = 1.7 gnits

SUBDIRS = lib po src tests man

ACLOCAL_AMFLAGS = -I m4

EXTRA_DIST = Makefile.cfg Makefile.maint GNUmakefile \
  .prev-version announce-gen

distcheck-hook:
	$(MAKE) my-distcheck
