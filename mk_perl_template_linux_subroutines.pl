=pod

=head2 Local script (mk_perl_template_linux) subroutines.

=head3 sub generate_globalsfile

I<Parameters>

$fp        -- file handle of file to receive output of subroutine$in_file        -- name of the input file (This is just a sample parameter.)

I<Returns>

Nothing

=cut
sub generate_globalsfile {
  my ($fp) = shift;
  print $fp "=pod\n\n";
  print $fp "=head1 Pragmas / Module inclusions:\n\n";
  print $fp "=cut\n";
  print $fp "use strict;\n";
  print $fp "use Cwd;\n";
  print $fp "use Getopt::Long\n";
  print $fp "\n";
  print $fp "=pod\n";
  print $fp "\n";
  print $fp "=head1 Global variable declarations\n";
  print $fp "\n";
  print $fp "=cut";
} ## end sub generate_globalsfile

=pod

=head3 sub generate_mainfile

I<Parameters>

$fp        -- file handle of file to receive output of subroutine$in_file        -- name of the input file (This is just a sample parameter.)

I<Returns>

Nothing

=cut
sub generate_mainfile {
  my ($fp) = shift;
  print $fp "=pod\n\n";
  print $fp "=head1 Main Program Structure\n\n";
  print $fp "=head2 Code block INIT_GLOBALS\n\n";
  print $fp "=cut\n";
  print $fp "# Initialize parameters and global variables.\n\n";
  print $fp "INIT_GLOBALS: {\n";
  print $fp "  our \$help = 0;\n";
  print $fp "  #our \$var1 = \"\";\n";
  print $fp "  #our \$var2 = 0;\n";
  print $fp "  #our \$var3;\n";
  print $fp "  #our \$var4;\n";
  print $fp "\n\n";
  print $fp "  #===> See file:///home/jstaelen/Documents/perldoc-html/Getopt/Long.html\n";
  print $fp "  #===> Change #string# to desired prompt strings in the following.\n";
  print $fp "  GetOptions(\n";
  print $fp "    '#String-Param#=s' => \$var1,       # String variable\n";
  print $fp "    '#Integer-Param#=1' => \$var2,      # Boolean variable\n";
  print $fp "    '#Boolean-Param#' => \$var3,\n";
  print $fp "    '#...#' => \$var4,\n";
  print $fp "    'help' => \$help,                   # Boolean variable\n";
  print $fp '  );', "\n";
  print $fp "}\n\n";
  for ($x = 0; $x <= $#codeblock_name; $x++) {
    &generate_code_block($fp, $codeblock_name[$x], $codeblock_desc[$x]) if ($codeblock_name[$x]);
  }
  print $fp "=pod\n\n";
  print $fp "=head1 Subroutines (local and common) below this point.\n\n";
  print $fp "=cut";
} ## end sub generate_mainfile


=pod

=head3 <sub generate_local_subroutinesfile>

I<parameters>

$fp        -- file handle of file to receive output of subroutine

I<Returns>

Nothing

=cut
sub generate_local_subroutinesfile {
  my ($fp) = shift;
  print $fp "=pod\n\n";
  print $fp "=head1 Local script ($project) subroutines.\n\n";
  print $fp "=cut\n\n";
  print $fp "=pod\n\n";
  print $fp "=head1 Commonly used (library) subroutines.\n\n";
  print $fp "=cut";
} ## end sub generate_local_subroutinesfile

=pod

=head3 sub generate_pod_headfile

I<Parameters>

$fp        -- file handle of file to receive output of subroutine

I<Returns>

Nothing

=cut
sub generate_pod_headfile {
  my ($fp)      = shift;

  print $fp "#!", `which perl`, "\n";
  my ($example) ="file:///" . $MPT_source_code_location . "/" .$project . "_sample.jpg";
  $example =~ s/\//\//g;
  print $fp "=pod\n\n";
  print $fp "I<Source code location:>\n\n";
  print $fp "C<$MPT_source_code_location>";
  print $fp "\n\n";
  print $fp "=head1 Synopsis\n\n";
  print $fp "Replace this with your own description.\n\n";
  print $fp "=head2 Usage\n\n";
  print $fp "C<perl $script [Parameter list]>\n\n";
  print $fp "=head2 Parameters:\n\n";
  print $fp "C<Describe parameter 1 here>\n\n";
  print $fp "C<Describe parameter 2 here>\n\n";
  print $fp "C<etc.>\n\n";
  print $fp "=head2 Example\n\n";
  print $fp "Put sample invocation of program here.\n\n";
  print $fp "I<Sample of result:>\n\n";
  print $fp "  Copy sample output to here.  Indent by two spaces if you want\n";
  print $fp "  to display output in a monospaced font.\n\n";
  print $fp "Note: If any of the following images exist at the target install location";
  print $fp "  they should show up in the documentation file $project.pl.html.\n\n";
  print $fp "=begin html\n\n";

=pod

This next line will show the example image saved in the program source folder

=cut
  print $fp '<img src="', $example, '">', "<br>\n";

=pod

The next set of lines will show the example image stored in the various program
installation locations.

=cut
  foreach $opsys (sort(keys %net_install_folders)) {
    if ($net_install_folders{$opsys}{'AllUsersPrograms'}) {
      my ($example) = "/" . $project . "_sample.jpg";
      $example = $net_install_folders{$opsys}{'AllUsersPrograms'} . $example;
      #$example =~ s/\//\\/g;
      print $fp '<img src="', $example, '">', "\n";
    } ## end if ($net_install_folders...)
  } ## end foreach $opsys (sort(keys %net_install_folders...))
  print $fp "\n";
  print $fp "=end html\n\n";
  print $fp "=head1 Implementation\n\n";
  print $fp "Describe any special circumstances for using the script.\n\n";
  print $fp "=cut";
} ## end sub generate_pod_headfile

=pod

=head3 sub generate_pod_tailfile

I<Parameters>

$fp        -- file handle of file to receive output of subroutine

I<Returns>

Nothing

=cut
sub generate_pod_tailfile {
  my ($fp) = shift;
  print $fp "=head1 Credits\n\n";
  print $fp "Put some stuff here if you want to credit someone else.\n\n";
  print $fp "=head1 Bugs\n\n";
  print $fp "None, so far.\n\n";
  print $fp "=head1 Author\n\n";
  print $fp "John Staelens\n\n";
  print $fp "=head1 Support\n\n";
  print $fp "Call John Staelens at (413) 743-7682\n\n";
  print $fp "=head1 Change Log\n\n\n\n";
  print $fp "=cut";
} ## end sub generate_pod_tailfile

=pod

=head3 sub find_this_script_base

I<Parameters>

None

I<Returns>

  Base path for this script.

=cut
sub find_this_script_base {
  my ($src, @path);

  $src=`pwd`;
  @path=split(/\//, $src);
  return join("/", @path[0..($#path - 1)]);
} ## end sub find_this_script_base

=pod

=head3 sub generate_code_block

I<parameters>

$fp         ---> pointer to opened file

$blockname  ---> name of codeblock to be created

$purpose    ---> description of purpose of block ---> optional

I<Returns>

Nothing

=cut
sub generate_code_block {
  my ($fp, $blockname, $purpose) = @_;

  print $fp "=pod\n\n";
  print $fp "=head2 Code block $blockname ---> ";
  unless ($purpose) {
    print $fp "<Insert description of purpose here>.\n\n";
  }
  else {
    print $fp "$purpose.\n\n";
  }
  print $fp "=cut\n\n";
  print $fp "$blockname: {\n";
  print $fp "}\n\n";
} ## end sub generate_code_block
