#!@PERL@ -w
# Filter C code so that CPP #-directives are indented to reflect nesting.
# written by Jim Meyering

# This code is included here solely to provide a little perspective
# on the development process and evolution of the package.  The Lex/C
# version is much more efficient.

use strict;

my $checking = 0;
if (@ARGV && $ARGV[0] eq '-c')
  {
    shift @ARGV;
    $checking = 1;
  }
unshift (@ARGV, '-') if @ARGV == 0;

die "usage: $0 [FILE]\n" if @ARGV > 1;

my $file = shift @ARGV;
my $exit_status = cpp_indent ($file, $checking);

exit ($exit_status);

# ===============================

# Return 2 for syntax problems.
# Return 1 for invalid indentation of CPP #-directives (only if $checking).
# if checking
#   return 0 if syntax and indentation are valid
# else
#   if (syntax is valid)
#     {
#       print properly indented code to stdout
#       return 0
#     }
sub cpp_indent ($$)
{
  my ($file, $checking) = @_;
  my $start_of_last_comment_or_string;

  sub IN_CODE {1}
  sub IN_COMMENT {2}
  sub IN_STRING {3}
  sub update_state ($$)
  {
    my ($state, $line) = @_;

    my $new_string_or_comment = 0;
    while ($line)
      {
	#warn "s: $state: line=$line";
	my $remainder = '';
	if ($state == IN_CODE)
	  {
	    my $i = index ($line, '"');
	    my $j = index ($line, '/*');
	    last if ($i < 0 && $j < 0);

	    # A double quote inside single quotes doesn't count.
	    $i = -1 if substr ($line, $i - 1, 1) eq "'";

	    my $k;
	    if ($i < 0)
	      {
		last if $j < 0;
		$k = $j;
	      }
	    else
	      {
		if ($j < 0)
		  {
		    $k = $i;
		  }
		else
		  {
		    $k = ($i < $j ? $i : $j);
		  }
	      }
	    $state = ($k == $i ? IN_STRING : IN_COMMENT);
	    $remainder = substr ($line, $k + 1);
	    $new_string_or_comment = 1;
	  }
	elsif ($state == IN_COMMENT)
	  {
	    if ($line =~ m!\*/!g)
	      {
		$state = IN_CODE;
		$remainder = $';
	      }
	  }
	else # $state == IN_STRING
	  {
	    if ($line =~ m!\\*\"!)
	      {
		$state = IN_CODE if (length ($&) % 2 == 1);
		$remainder = $';
	      }
	  }
	$line = $remainder;
      }

    return ($state, $new_string_or_comment);
  }
  # ===============================================================

  # TODO: allow this to be overridden by a command-line option.
  my $indent_incr = ' ';

  my @opener_stack;
  my $depth = 0;

  open (FILE, $file) || die "$0: couldn't open $file: $!\n";

  my $fail = 0;
  my $state = IN_CODE;
  my $line;
  while (defined ($line = <FILE>))
    {
      my $rest;

      if ($state == IN_CODE)
	{
	  my $saved_line = $line;
	  if ($line =~ s/^\s*\#\s*//)
	    {
	      my $keyword;
	      my $indent;
	      my $pfx = "$0: $file: line $.";
	      if ($line =~ /^if\b/
		  || $line =~ /^ifdef\b/
		  || $line =~ /^ifndef\b/)
		{
		  # Maintain stack of (line number, keyword) pairs to better
		  # report any `unterminated #if...' errors.
		  push @opener_stack, {LINE_NUMBER => $., KEYWORD => $&};
		  $keyword = $&;
		  $indent = $indent_incr x $depth;
		  ++$depth;
		}
	      elsif ($line =~ /^(else|elif)\b/)
		{
		  if ($depth < 1)
		    {
		      warn "$pfx: found #$& without matching #if\n";
		      $depth = 1;
		      $fail = 2;
		    }
		  $keyword = $&;
		  $indent = $indent_incr x ($depth - 1);
		}
	      elsif ($line =~ /^endif\b/)
		{
		  if ($depth < 1)
		    {
		      warn "$pfx: found #$& without matching #if\n";
		      $depth = 1;
		      $fail = 2;
		    }
		  $keyword = $&;
		  --$depth;
		  $indent = $indent_incr x $depth;
		  pop @opener_stack;
		}
	      else
		{
		  # Handle #error, #include, #pragma, etc.
		  $keyword = '';
		  $indent = $indent_incr x $depth;
		}

	      if ($checking && $saved_line ne "#$indent$keyword$'")
		{
		  warn "$pfx: not properly indented\n";
		  close FILE;
		  return 1;
		}

	      $line = "#$indent$keyword$'";
	      $rest = $';
	    }
	  else
	    {
	      $rest = $line;
	    }
	}
      else
	{
	  $rest = $line;
	}
      #print $state if !$checking;
      print $line if !$checking;

      my $new_non_code;
      ($state, $new_non_code) = update_state ($state, $rest);
      $start_of_last_comment_or_string = $.
	if $new_non_code;
    }
  close FILE;

  if ($depth != 0)
    {
      my $x;
      foreach $x (@opener_stack)
	{
	  warn "$0: $file: line $x->{LINE_NUMBER}: "
	    . "unterminated #$x->{KEYWORD}\n";
	}
      $fail = 2;
    }

  if ($state != IN_CODE)
    {
      my $type = ($state == IN_COMMENT && 'comment' || 'string');
      warn "$0: $file: line $start_of_last_comment_or_string "
	. "unterminated $type\n";
      $fail = 2;
    }

  return $fail;
}
