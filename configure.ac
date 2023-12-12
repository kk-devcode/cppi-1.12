# Process this file with autoconf to produce a configure script.
AC_INIT([GNU cppi],[1.12],[bug-cppi@gnu.org])
AC_CONFIG_SRCDIR(src/cppi.l)

AC_CONFIG_AUX_DIR(build-aux)
AM_CONFIG_HEADER(config.h:config.hin)

AM_INIT_AUTOMAKE([1.9.3 gnits dist-bzip2])

AM_MISSING_PROG(HELP2MAN, help2man)
AC_PROG_CC
gl_EARLY
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_LEX
AC_PROG_RANLIB

gl_INIT

AC_C_INLINE
AC_HEADER_DIRENT

GNU_PACKAGE="GNU $PACKAGE"
AC_DEFINE_UNQUOTED(GNU_PACKAGE, "$GNU_PACKAGE",
  [The concatenation of the strings `GNU ', and PACKAGE.])
AC_SUBST(GNU_PACKAGE)

GNULIB_AUTOCONF_SNIPPET

AM_GNU_GETTEXT_VERSION(0.13.1)

AC_CONFIG_FILES(
  Makefile
  lib/Makefile
  po/Makefile
  src/Makefile
  tests/Makefile
  man/Makefile)

AC_OUTPUT
