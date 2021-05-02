=pod

=head3 sub usage

B<Provenance>

This usage subroutine was created  by executing command:

  perl /usr/local/bin/generate_sub_usage.pl "/media/HGST8TB/linux-shared/Scripts/DevelopmentTools/mk_perl_template_linux/source"\
    "--project=project_name deploy debug help"\
    "This script builds a template set of files in the current working directory.  Note that project_name must not have a filename extension (eg. .pl)."

It uses ANSI terminal escape codes to accentuate and colorize the usage display.

For a listing of the color codes and directives, see:
See /media/HGST8TB/linux-shared/Scripts/common/perl/initializeANSI/initializeANSI_main.pl

--- IT IS UP TO THE USER TO FURTHER CUSTOMIZE THE GENERATED SUBROUTINE. ---

I<Parameters>

None

I<Returns>

Nothing

=cut

sub usage {
  use initializeANSI;
  initializeANSI;

  print "${Byellowf}", UNDERLINE, "USAGE:", RESET, "\n\n";
  print "${Bwhitef}", ITALIC, "    perl /usr/local/bin/mk_perl_template_linux.pl   \"--project=project_name\", \"deploy\", \"debug\", \"help\"" , RESET, "\n\n";
  print "${Bcyanf}" , ITALIC, '    This script builds a template set of files in the current working directory.  Note that project_name must not have a filename extension (eg. .sh).', RESET, "\n\n";
  print "${Byellowf}", ITALIC, "    Example case:" , RESET, "\n";
  print "${Bcyanf}"  , ITALIC, "        mkdir /media/HGST8TB/linux-shared/Scripts/test_mk_shell_template" , RESET, "\n";
  print "${Bcyanf}"  , ITALIC, "        cd /media/HGST8TB/linux-shared/Scripts/test_mk_shell_template" , RESET, "\n";
  print "${Bcyanf}"  , ITALIC, "        perl /usr/local/bin/mk_shell_template.pl --project=test_mk_shell_template 1 1" , RESET, "\n\n";
  print "${Byellowf}", UNDERLINE, "PARAMETERS:", RESET, "\n\n";
  print "${Bwhitef}", ITALIC, "    \$--project=project_name -- ", "${Bcyanf}", "Name for the script: should match the directory above the source files.", "\n\n";
  print "${Bwhitef}", ITALIC, "    \$deploy                 -- ", "${Bcyanf}", "If this has a value, the project script will be deployed to /usr/local/bin", "\n\n";
  print "${Bwhitef}", ITALIC, "    \$debug                  -- ", "${Bcyanf}", "If not blank, adds some tracing info to the project build.", "\n\n";
  print "${Byellowf}", UNDERLINE, "IMPLEMENTATION:", RESET, "\n\n";
  print "${Bwhitef}" , ITALIC, '    Start my creating a target directory for the build project. (See Simplest Case above).', RESET, "\n";
  print "${Bwhitef}" , ITALIC, '    Change directory to the target directory', RESET, "\n";
  print "${Bwhitef}" , ITALIC, '    Issue the mk_shell_template command', RESET, "\n";
}
