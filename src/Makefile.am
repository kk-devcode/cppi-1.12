## Process this file with automake to produce Makefile.in -*-Makefile-*-

bin_PROGRAMS = cppi
cppi_SOURCES = \
  cppi.l \
  system.h

EXTRA_DIST = cpp.gp cpp-indent.pl cppi.l cpp-cond.c
MAINTAINERCLEANFILES = cpp-cond.c
CLEANFILES = cpp.h lex.backup

GPERF = gperf

AM_CPPFLAGS = -I.. -I$(srcdir) -I$(top_srcdir)/lib -I../lib

LDADD = ../lib/libcppi.a $(LIBINTL) ../lib/libcppi.a

cpp-cond.c: cpp.gp
	rm -f $@ $@-tmp
	$(GPERF) -a -C -N cpp_cond_lookup -n -p -t -s 6 -k '*' $< \
	  > $@-tmp
	chmod a-w $@-tmp
	mv $@-tmp $@

localedir = $(datadir)/locale
BUILT_SOURCES = localedir.h
DISTCLEANFILES = localedir.h
localedir.h: Makefile
	@rm -f $@-t
	echo '#define LOCALEDIR "$(localedir)"' >$@-t
	@chmod a-w $@-t
	cmp $@-t $@ > /dev/null 2>&1 && rm -f $@-t || { rm -f $@; mv $@-t $@; }

# flex_debug = #-d
flex_debug = # -L # suppress #line directives

# This is required to avoid an infloop on certain 8-bit inputs.
# Without this option, the generated scanner would infloop on e.g.,
#   perl -e 'print "\300"' |./cppi
flex_8_bit = -8

flex_optimize = -Cfr -p -b
AM_LFLAGS = $(flex_debug) $(flex_optimize) $(flex_8_bit)

# Don't use automake's default .l.c rule.
# I prefer to make generated .c files unwritable.
cppi.c: cppi.l
	rm -f $@
	$(LEXCOMPILE) $(srcdir)/cppi.l
	chmod a-w $(LEX_OUTPUT_ROOT).c
	mv $(LEX_OUTPUT_ROOT).c $@

cpp.h: cpp.gp Makefile.am
	@rm -f $@-tmp $@
	@(								\
	 echo '/* This file is generated automatically from cpp.gp.  */'; \
	 echo;								\
	 echo 'enum Eic_type';						\
	 echo '{';							\
	 sed -n '/.*, /{s///;s/.*/  &,/;p;};' $(srcdir)/cpp.gp;		\
	 echo '  EIC_OTHER';						\
	 echo '};';							\
	 echo;								\
	 echo 'static char const *const directive[] =';			\
	 echo '{';							\
	 sed -n '/,.*/{s///;s/.*/  "&",/;p;};' $(srcdir)/cpp.gp;	\
	 echo '  ""';							\
	 echo '};';							\
	)								\
	  > $@-tmp
	@chmod -w $@-tmp
	@mv $@-tmp $@

BUILT_SOURCES += cpp-cond.c cpp.h

# The following rule is not designed to be portable,
# and relies on tools that not everyone has.

# Most functions in src/*.c should have static scope.
# Any that don't must be marked with `extern', but `main'
# and `usage' are exceptions.  They're always extern, but
# don't need to be marked.
#
# The second nm|grep checks for file-scope variables with `extern' scope.
sc_tight_scope: $(all_programs)
	@t=exceptions-$$$$;						\
	trap "s=$$?; rm -f $$t; exit $$s" 0 1 2 13 15;			\
	( printf '^main$$\n^usage$$\n^cpp_cond_lookup$$\n^yy\n';	\
	  grep -h -A1 '^extern .*[^;]$$' $(SOURCES)			\
	    | grep -vE '^(extern |--)' |sed 's/^/^/;s/ .*/$$/' ) > $$t;	\
	nm -e *.$(OBJEXT)						\
	    | sed -n 's/.* T //p'					\
	    | grep -Ev -f $$t &&					\
	  { echo 'the above functions should have static scope' 1>&2;	\
	    exit 1; } || : ;						\
	( printf '^program_name$$\n^yy\n';					\
	  test x"$(noinst_HEADERS)" = x ||				\
	  sed -n 's/^extern int \([^ ][^ ]*\);$$/^\1$$/p'		\
	    $(noinst_HEADERS) ) > $$t;					\
	nm -e *.$(OBJEXT)						\
	    | sed -n 's/.* [BD] //p'					\
	    | grep -Ev -f $$t &&					\
	  { echo 'the above variables should have static scope' 1>&2;	\
	    exit 1; } || :
