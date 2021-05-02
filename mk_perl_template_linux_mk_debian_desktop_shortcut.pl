=pod

=head3 sub mk_debian_desktop_shortcut

Creates a text file to be placed in either /usr/share/applications (all users application menu)
 or ./.local/share/applications (local user application menu).  For reference see
 http://xmodulo.com/create-desktop-shortcut-launcher-linux.html

Assumes that program icon will be .png format, be named after the program and will be installed in
an icons subfolder of program script.

I<Parameters>

  $fp         -- pointer to shortcut .desktop text file
  $sloc       -- shortcut location
  $pname      -- program name
  $pdesc      -- short program description
  $ploc       -- program location
  $useterm    -- run in terminal (1 for yes, else no)
  $comment    -- longer program description

I<Returns>

  Nothing
=cut
sub mk_debian_desktop_shortcut {
  ($fp, $pname, $pdesc, $ploc, $useterm, $comment) = @_;
  my ($fmt) = "%60s# %s\n";
  my ($fullpath) = "$ploc/$pname.pl";
  my ($icon)  = "$ploc/icons/$pname.png";
  my ($termflag) = ($useterm == 1) ? "true" : "false";

  print $fp "[Desktop Entry]\n";
  print $fp "Encoding=UTF-8\n";
  printf($fp $fmt, "Version=1.0", "Version of application");
  printf($fp $fmt, "Name[en_US]=$pname", "Name of Application");
  printf($fp $fmt, "GenericName=$pdesc", "Short description of application");
  printf($fp $fmt, "Exec=perl $fullpath", "Command used to launch application");
  printf($fp $fmt, "Terrminal=$useterm", "whether an app requires to be run in a terminal.");
  printf($fp $fmt, "Icon[en_US]=$icon", "location of icon file");
  printf($fp $fmt, "Type=Application", "type");
  printf($fp $fmt, "Categories=Application", "categories in which this app should be listed");
  printf($fp $fmt, "Comment[en_US]=$comment", "comment which appears as a tooltip");
}