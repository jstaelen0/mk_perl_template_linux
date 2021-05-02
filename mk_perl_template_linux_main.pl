=pod

=head1 Main Program Structure

This is simple, straight line code.  There are 9 code blocks.  Each one writes
a separate template file.

=head2 Code Block INIT_COMMON_FILES ---> Push user selected common files onto @common_files

=cut
INIT_COMMON_FILES: {
  foreach my $k (%subroutines) {
    if ($selected_subroutines{$k}) {
      push @common_files, $k;
    }
  }

  if ($debugging) {
    print "Installed program location       = $MPT_program_location\n";
    print "Create shortcut to program in    = $MPT_shortcut_location\n";
    print "Base of Scripts files            = $base_dir\n";
    print "Common source                    = $common_source\n";
    print "Program source code location     = $MPT_source_code_location\n";
    print "Name of script to be built       = $script\n";
    print "makefile                         = $makefile\n";
    print "parts                            = $parts\n";
    print "css                              = $css\n";
    print "main                             = $main\n";
    print "subroutines                      = $subroutines\n";
    print "pod_head                         = $pod_head\n";
    print "pod_tail                         = $pod_tail\n";
    print "icon                             = $icon\n";
    if ( -f $sample ) { print "sample                           = $sample\n"; }
    print "readme                           = $readme\n";
    print "Shortcut creator script name     = $shortcut_creator\n";
  } ## end if ($debugging)
}

=pod

=head2 Code Block CREATE_SOURCE_LOCATION ---> Build the file tree leading to the target project source location

=cut
CREATE_SOURCE_LOCATION: {
  my (@path, $this_dir, $current_path);
  @path = split(/\//, $MPT_source_code_location);
  foreach $this_dir (@path) {
    if ($this_dir) {
      $current_path .= "/$this_dir";
      unless (-d $current_path) {
        unless (mkdir $current_path) {
          tk_emsg("CREATE_SOURCE_LOCATION:", "Source directory creation failed at $current_path: $!");
          exit 1;
        }
      } ## end unless (-d $current_path)
    } ## end if ($this_dir)
  } ## end foreach $this_dir (@path)
} ## end CREATE_SOURCE_LOCATION:

# Set up the basic files names for the source code fragments and installer files
$script = $project . ".pl";

=pod

=head2 Code Block MAKEFILE ---> Set up the basic files names for the source code fragments and installer files and create the project Makefile

=cut
MAKEFILE: {
  my ($target) = substr($script, 0, length($script)-3);
  my ($shell_ext) = substr($script, -3);
  #my ($debugging) = 0;
  &sub_generate_makefile("--directory=$MPT_source_code_location", "--name=$target", "--filename_ext=$shell_ext", \
    "--deploy_to=$MPT_program_location", "--debug_flag=$debugging");
}

=pod

=head2 Code Block POD_HEAD ---> Generate the <project>_pod_head.pl file

=cut
POD_HEAD: {
  open($outp, ">", ($pod_head)) or die "Couldn't open '$pod_head' in write mode: $!";
  print $outp "#!", $perl_prg, "\n\n";
  &generate_pod_headfile($outp);
  close $outp;
}

=pod

=head2 Code Block GLOBALS ---> Generate the <project>_globals.pl file

=cut
GLOBALS: {
  open($outp, ">", ($globals)) or die "Couldn't open '$globals' in write mode: $!";
  &generate_globalsfile($outp);
  close $outp;
}

=pod

=head2 Code Block MAIN ---> Generate the <project>_main.pl file.

This will include any code blocks defined through the graphical user interface.

=cut
MAIN: {
  open($outp, ">", ($main)) or die "Couldn't open '$main' in write mode: $!";
  &generate_mainfile($outp);
  close $outp;
}

=pod

=head2 Code Block SUBROUTINES ---> Generate the <project>_subroutines.pl file

=cut
SUBROUTINES: {
  open($outp, ">", ($subroutines)) or die "Couldn't open '$subroutines' in write mode: $!";
  &generate_local_subroutinesfile($outp);
  close $outp;
}

=pod

=head2 Code Block POD_TAIL ---> Generate the <project>pod_tail_.pl file

=cut
POD_TAIL: {
  open($outp, ">", ($pod_tail)) or die "Couldn't open '$pod_tail' in write mode: $!";
  &generate_pod_tailfile($outp);
  close $outp;
}

=pod

=head2 Code Block CREATE_DEFAULT_ICON_FILE ---> Create the default, generic program icon file for use in project shortcut creation.

=cut
CREATE_DEFAULT_ICON_FILE: {
  copy($default_icon, $icon)
    or die "Couldn't copy $default_icon to $icon";
}

exit 0;

=pod

I<Subroutines below this point>

=cut
