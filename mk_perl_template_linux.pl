
#!/usr/bin/perl
=pod

=head1 Program Summary

=I<Source code location:>

/media/HGST8TB/linux-shared/Scripts/DevelopmentTools/mk_perl_template_linux/source

head2 Synopsis

This script takes a project name and builds a minimum set of files that will
assemble into a complete Perl script by issuing the command "make" from the
project's "source" directory. The basic files must be edited to include the
variables, code and comments you need to make the script work as intended.

=head2 Usage

Simplest case:

C</usr/local/bin/mk_perl_template_linux.pl --project=script_basename>

=head2 Parameters:

=head3 --project=basename  Required string value; name of the new script project. Do not include the .pl extension. If not supplied, defaults to 'new_project'

=head3 --deploy=[dir_name] String value; defaults to /usr/local/bin if not supplied

=head3 --debug             Simple flag; defaults to 1 if not supplied

=head3 --help              Simple flag; defaults to 0 if not supplied

=head2 Example

First create and cd to the directory that will serve as the project base.  Ex.

C<mkdir /media/HGST8TB/linux-shared/Scripts/build_listings_table>

C<cd /media/HGST8TB/linux-shared/Scripts/build_listings_table>

Next execute

B<perl /usr/local/bin/mk_perl_template_linux.pl --project=build_listings_table>

This window will open to allow changing of various settings.

I<This shows the grapical interface in the case where Code Blocks have not been pre-defined
in a file named $(project).blocks.  The code block entry lines do not appear if the .blocks
file is present.>

=begin html

<img src="Screenshot from 2020-10-17 22-58-21.png">

=end html

I<Only the checkboxes with white backgrounds are active.>

This window may look different depending on your version of perl.  This version shows
all check boxes checked, but the background color of the checkboxes varies
between gray and white.

The topmost data field is directly editable.

Clicking in the Source Code Directory field brings up a file browser where you can change the location.

Closing the selection window with the settings shown results in the creation of the following
files in folder /media/HGST8TB/linux-shared/Scripts/build_listings_table/source:

C<create_build_listings_table_shortcut.pl>

C<build_listings_table.css>

C<build_listings_table.parts>

C<build_listings_table_globals.pl>

C<build_listings_table_Install.txt>

C<build_listings_table_main.pl>

C<build_listings_table_pod_head.pl>

C<build_listings_table_pod_tail.pl>

C<HowTo_Install_build_listings_table.txt>

C<Makefile>

=head2 Implementation

When invoked, mk_perl_template_linux.pl opens a graphical interface in which you can change the project name,
project source code directory, and the set of commonly used perl subroutines to be included
in the project.

This script reads the contents of "/media/HGST8TB/linux-shared/Scripts/common/perl/create_shortcut/create_shortcut_main.pl"
when it constructs the shortcut builder script.

The script assumes that you will add an icon file to the source directory which is named
in the format $project.ico.  It also assumes that you will add a screen capture of
the project program output, named in the format $project_example.jpg.  The screen capture
is incorporated in the project _pod_head.pl file.

Multiple net_install templates are created for use with various target operating
systems.  Read the generated HowTo_Install file for hints on the install process.

This script is only useful for the John Staelens working on his home computer.

=cut



=head1 Start of Program Code

B<Pragmas / Module inclusions:>

=cut
use warnings;
use Cwd;
use Tkx;
use File::Copy;
use File::Temp qw/ tempfile tempdir /;
use Getopt::Long;
use sub_generate_makefile;
use mk_shell_template_text_drawing_functions;

=pod

B<Global variable declarations:>

=cut
our ($project, $deploy_to, $help) = ('', '/usr/local/bin', 0);
our ($debugging);
our ($perl_prg);
our ($base_dir, $common_base, $common_source);
our ($fp);

=pod

I<To hold names of basic files>

=cut
our (
     $about, $makefile, $net_install, $about_pl, $globals,
     $main, $subroutines, $pod_head, $pod_tail, $readme,
     $script, $shortcut_creator, $icon,
     $sample, $css, $default_icon
);

=pod

I<@codeblock_name and @codeblock_desc will hold names and descriptions.>

I<@NroffOutPut will hold data returned from the external linux program fmt>

=cut
our (@codeblock_name, @codeblock_desc);
our ($MPT_code_block_label1, $MPT_code_block_label2);
our ($MPT_code_block_label, @PPT_code_block_display_name, @PPT_code_block_display_desc);
our ($MPT_code_block_frame);

our ($Date,        $Time);
our (%subroutines, %selected_subroutines);
our ($outp);

=pod

These will be stock subroutines from the /media/HGST8TB/linux-shared/Scripts/common/perl directory

=cut
our (@common_files);

=pod

I<Installation location lookups on various flavors of Windows>

=cut
our (%net_install_folders) = ('linux'     => 'linux_special_folders');

=pod

I<Installation instructions lookups on various flaovors of OS>

=cut
our (%net_install_files) = ('linux'     => 'net_install_linux.csv');

=pod

I<Variables used by the Tk graphical interface>

=cut
our ($MPT_source_code_location, $MPT_program_location,  $MPT_shortcut_location);
our ($app_title,                $MPT_project_frame,     $MPT_project_label, $MPT_project_display);
our ($MPT_source_code_frame,    $MPT_source_code_label, $MPT_source_code_display);
our ($MPT_common_subs_frame,    $MPT_common_subs_label, $MPT_common_subs_display);
our ($MPT,                      $MPT_Title_Frame,       $MPT_Progress_Frame, $MPT_Menu_Bar);
our (
     $MPT_Selections_Frame,           $MPT_program_location_frame,
     $MPT_shortcut_location_frame,
     $MPT_program_location_label,
     $MPT_program_location_display,   $MPT_shortcut_location_label,
     $MPT_shortcut_location_display
);
our ($lable_background,         $lable_foreground);
our ($data_background,          $data_foreground);
our ($app_background,           $app_foreground, $app_activebackground);
our ($button_activebackground1, $button_activebackground2);
our ($datebutton_background,    $datebutton_foreground);
our ($readonly_background,      $readonly_foreground);
our ($cancel_button_active_color);

=pod

=head2 Code block INIT_GLOBALS

I<Initialize global variables.>

=cut
INIT_GLOBALS: {
  GetOptions('project=s' => \$project,
             'deploy=s'  => \$deploy_to,
             'debug'     => \$debugging,
             'help'      => \$help);

  $help = 1 unless ($project);
  if ($help) { &usage; exit 0; }
  unless ($project) { $project = "new_project"; }
  unless ($deploy_to) { $deploy_to = '/usr/local/bin'; }
  unless ($debugging) { $debugging = 0; }
  &GetDateTime(\$Date, \$Time, 4);
  $perl_prg = `which perl`;

=pod

I<If there is a file in the current directory with the name of the project and a ".blocks">
I<extension, then we read from it the names and descriptions of the code blocks t0 build>
I<into the main project file.>

=cut
  our $infile = join(".", $project , "blocks");
  if (-e $infile) {
    my (@tmp);
    open(INP, "<", $infile) or die "Couldn't open $infile in read mode: $!";
    while ($_ = <INP>) {
      if (length($_) > 2) {
        chomp $_;
        @tmp = split(/ /, $_);
        push @codeblock_name, uc $tmp[0];
        push @codeblock_desc, join(" ", @tmp[1..$#tmp]);
      }
    }
    close(INP);
  }

=pod

I<Set some initial choices for file locations.>
I<1. Location into which the new program will be installed.>

=cut
  $MPT_program_location = $deploy_to;

=pod

I<2. Location into which a shorcut to the new program will be installed.>
I<This is incorrect.  Linux has no equivalent of AllUsersDesktop>

=cut
  $MPT_shortcut_location = "/usr/share/applications";

=pod

I<3. Where the project files will be created>

=cut
  my $cur_dir = getcwd;
  my @path_parts = split('/', $cur_dir);
  for ($x = 0; $x <= $#path_parts; $x++) {
    if ($x == 0) {
      $base_dir = $path_parts[$x];
    }
    else {
      $base_dir .= ("/" . $path_parts[$x]);
    }
    if ($path_parts[$x] =~ /Scripts/) {
      $x = $#path_parts;
    }
  }
  $common_base = "/media/HGST8TB/linux-shared/Scripts";
  $common_source = $base_dir . "/common/perl";
  $cur_dir = "/" . join('/', @path_parts[1 .. ($#path_parts - 1)]);
  $MPT_source_code_location = $cur_dir . "/$project/source";
  $MPT_code_block_label1 = "Code Block Name:";
  $MPT_code_block_label2 = "Code Block Purpose:";

=pod

I<Get a list of perl subroutines from /Scripts/common/perl directory>

=cut
  &get_list_of_common_perl_subroutines(\%subroutines);

=pod

Preselect some commonly used subroutines.

=cut
  foreach my $key (keys(%subroutines)) {
    if ($key =~ 'script_self_identify') {
      $selected_subroutines{$key}     = 1;
    }
    elsif ($key =~ 'JulianDateRoutines') {
      $selected_subroutines{$key}     = 1;
    }
    elsif ($key =~ 'tk_emsg') {
      $selected_subroutines{$key}     = 1;
    }
    elsif ($key =~ 'GetDateTime') {
      $selected_subroutines{$key}     = 1;
    }
  }

=pod

I<Launch the graphical interface to let user modify default file locations>

=cut
  &activate_form;

=pod

I<Set up the basic files names for the source code fragments and installer files>

=cut
  $script           = $MPT_source_code_location . "/" . $project . ".pl";
  $makefile         = $MPT_source_code_location . "/" . "Makefile";
  $net_install      = $MPT_source_code_location . "/" . "net_install.csv";
  $parts            = $MPT_source_code_location . "/" . $project . ".parts";
  $globals          = $MPT_source_code_location . "/" . $project . "_globals.pl";
  $main             = $MPT_source_code_location . "/" . $project . "_main.pl";
  $subroutines      = $MPT_source_code_location . "/" . $project . "_subroutines.pl";
  $pod_head         = $MPT_source_code_location . "/" . $project . "_pod_head.pl";
  $pod_tail         = $MPT_source_code_location . "/" . $project . "_pod_tail.pl";
  $default_icon     = $base_dir . "/DevelopmentTools/mk_perl_template_linux/source/mk_perl_template_linux.ico";
  $icon             = $MPT_source_code_location . "/" . $project . ".ico";
  $sample           = $MPT_program_location . "/" . $project . "_sample.jpg";
  $readme           = $MPT_source_code_location . "/" . "HowTo_Install_" . $project . ".txt";
  $shortcut_creator = $MPT_source_code_location . "/" . "create_" . $project . "_shortcut.pl";
  $css              = $MPT_source_code_location . "/" . $project . ".css";
} ## end INIT_GLOBALS:



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



=pod

=head1 Local script subroutines.

=head3 <sub activate_form>

Creates the graphical user interface

I<parameters>

None

I<Returns>

Nothing

=cut
sub activate_form {
  $app_title                  = "PERL PROGRAM TEMPLATE GENERATOR for LINUX";
  $lable_background           = "SlateGray2";
  $lable_foreground           = "firebrick2";
  $data_background            = "black";
  $data_foreground            = "PaleGreen1";
  $app_background             = "purple";
  $app_foreground             = "white";
  $app_activebackground       = "cyan";
  $datebutton_background      = $data_background;
  $datebutton_foreground      = $data_foreground;
  $button_activebackground1   = "PaleGreen1";
  $button_activebackground2   = "PaleGreen3";
  $readonly_background        = "gray";
  $readonly_foreground        = 'black';
  $cancel_button_active_color = "DeepPink1";
  ##### End of variable initialization section #####

  # Gather all the needed data into arrays and hashes

  # Create main window
  $MPT = Tkx::widget->new(".");
  $MPT->g_wm_title("Perl Program Template Generator");
  $MPT->g_grid_columnconfigure(0, -weight => 1);
  $MPT->g_grid_rowconfigure(0, -weight => 1);

  $MPT_Selections_Frame = $MPT->new_frame();
  $MPT_Selections_Frame->g_grid(-column => 0, -row => 0, -stick => "nwes");
  &populate_selections_frame;

  $MPT_Menu_Bar = $MPT->new_frame();

  Tkx::MainLoop();
  1;
} ## end sub activate_form

=pod

=head3 <sub populate_selections_frame>

Populates the various user interface selection boxes.

I<parameters>

None

I<Returns>

Nothing

=cut
sub populate_selections_frame {

=pod

This frame shows the base name for the new project files

=cut
  $MPT_project_frame = $MPT_Selections_Frame->new_frame();
  $MPT_project_frame->g_grid(-column => 1, -row => 1);

=pod

This frame shows the local directory where the project template files will be created.

=cut
  $MPT_source_code_frame = $MPT_Selections_Frame->new_frame();
  $MPT_source_code_frame->g_grid(-column => 1, -row => 2);

=pod

This frame shows labels and boxes for user declared code blocks that will be inserted
into the mail file for the project.

=cut
  $MPT_code_block_frame = $MPT_Selections_Frame->new_frame();
  $MPT_code_block_frame->g_grid(-column => 1, -row => 3);

=pod

This frame shows checkboxes for common subroutines to be included in project

=cut
  $MPT_common_subs_frame = $MPT_Selections_Frame->new_frame();
  $MPT_common_subs_frame->g_grid(-column => 1, -row => 4);

  # -------------------------------------------------------------------------- #

  $MPT_project_label = $MPT_project_frame->new_label(
    -width => 24,
    -text => "Project name:");
  $MPT_project_label->g_grid(-column => 1, -row => 1);

  #$MPT_project_display = $MPT_project_frame->new_entry(-width => 110,-textvariable => \$project);
  $MPT_project_display = $MPT_project_frame->new_entry(-width => 60,-textvariable => \$project);
  $MPT_project_display->configure(
    -relief       => 'groove',
    -borderwidth  => 3,
    -background   => $data_background,
    -foreground   => $data_foreground
  );
  $MPT_project_display->g_grid(-column => 2, -row => 1);

  # -------------------------------------------------------------------------- #

    my $MPT_cancel_button = $MPT_project_frame->new_button(
      -text             => 'Cancel',
      -background       => $cancel_button_active_color,
      -activebackground => $button_activebackground2,
      -foreground       => 'yellow',
      -command          => sub {
        $MPT_project_frame->g_destroy;
        exit;
      }
    );
    $MPT_cancel_button->g_grid(-column => 3, -row => 1);

  # -------------------------------------------------------------------------- #

  $MPT_source_code_label = $MPT_source_code_frame->new_label(
    -anchor => 'e',
    -width => 24,
    -text        => 'Source Code Directory:'
  );
  $MPT_source_code_label->g_grid(-column => 1, -row => 2);

  $MPT_source_code_display = $MPT_source_code_frame->new_button(
  	-width	=> 78,
    -anchor => 'w',
    -textvariable => \$MPT_source_code_location,
    -command => sub {
        $MPT_source_code_location = Tkx::tk___chooseDirectory(
          -initialdir => $MPT_source_code_location,
        );
        $MPT_source_code_location =~ s/[A-Z]://;
        unless ($MPT_source_code_location =~ /source$/) {
          $MPT_source_code_location .= "/source";
        }
      }
    );
    $MPT_source_code_display->configure(
      -relief       => 'groove',
      -borderwidth  => 4,
      -background   => $data_background,
      -foreground   => $data_foreground
    );
  $MPT_source_code_display->g_grid(-column => 2, -row => 2);

  # -------------------------------------------------------------------------- #

=pod

This next section creates fill-in boxes for requested code blocks, but only if
there are no entries already loaded into the @codeblock_name and  @codeblock_desc
arrays.  See the INIT_GLOBALS section of file mk_perl_template_globals.pl.

=cut
  unless (scalar(@codeblock_name)) {
    for (my $x = 0; $x <= 5; $x++) {
      $MPT_code_block_label = $MPT_code_block_frame->new_label(
        -anchor => 'e',
        -width => 24,
        -text => $MPT_code_block_label1);
      $MPT_code_block_label->g_grid(-column => 1, -row => $x+1);

      $MPT_code_block_display_name[$x] = $MPT_code_block_frame->new_entry(-width => 35,-textvariable => \$codeblock_name[$x]);
      $MPT_code_block_display_name[$x]->configure(
        -relief       => 'groove',
        -borderwidth  => 3,
        -background   => $data_background,
        -foreground   => $data_foreground
      );
      $MPT_code_block_display_name[$x]->g_grid(-column => 2, -row => $x+1);

      $MPT_code_block_label = $MPT_code_block_frame->new_label(
        -anchor => 'e',
        -width => 19,
        -text => $MPT_code_block_label2);
      $MPT_code_block_label->configure(
        -relief       => 'groove',
        -borderwidth  => 3,
      );
      $MPT_code_block_label->g_grid(-column => 3, -row => $x+1);

      $MPT_code_block_display_desc[$x] = $MPT_code_block_frame->new_entry(-width => 93,-textvariable => \$codeblock_desc[$x]);
      $MPT_code_block_display_desc[$x]->configure(
        -relief       => 'groove',
        -borderwidth  => 3,
        -background   => $data_background,
        -foreground   => $data_foreground
      );
      $MPT_code_block_display_desc[$x]->g_grid(-column => 4, -row => $x+1);
    }
  }

  # -------------------------------------------------------------------------- #

  my ($x, @checkbox);
  $x = 0;
  $MPT_common_subs_label = $MPT_common_subs_frame->new_label(
    -width => 30,
    -text        => 'Include common subroutines:'
  );
  $MPT_common_subs_label->g_grid(-column => 1, -row => 3);

  foreach my $k (sort { "\L$a" cmp "\L$b" } keys %subroutines) {
    $checkbox[$x] = $MPT_common_subs_frame->new_checkbutton(
      -width => 150,
      -justify => 'left',
      -text => $k . " -- " . $subroutines{ $k },
      -anchor => 'w',
      -wraplength => 1200,
      -variable => \$selected_subroutines{ $k },
    );
    $checkbox[$x]->configure(
      -relief       => 'groove',
      -borderwidth  => 1,
    );
    $checkbox[$x]->g_grid(-column => 2, -row => (3+$x));
      $x += 1;
    }
} ## end sub populate_selections_frame


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


our (%linux_special_folders) = (
  'AllUsersDesktop'   =>  '',
  'AllUsersStartMenu' =>  '/usr/share/applications',
  'AllUsersPrograms'  =>  '/usr/local/bin',
  'AllUsersStartup'   =>  '',
  'Fonts'             =>  ''
);


=pod

=head3 sub get_list_of_common_perl_subroutines

I<Parameters>

$hash_ptr        -- pointer to hash that uses subroutine names as keys and
                    subroutine descriptions as values

I<Assumptions>

The source code for each subroutine resides in a subdirectory of /Scripts/common/perl
and the subdirectory has the same name as the subroutine.  Within the source code
directory there will be a file named <subname>_head.pl (e.g. beep_head.pl).  Within the
head file the program description will follow the first line starting with '=head'.

I<Returns>

  Nothing

=cut
use File::Glob;
use File::Basename;

sub get_list_of_common_perl_subroutines {
  my ($sub_hash_ptr) = shift;
  my ($sub_location) = $common_base . "/common/perl/";
  my (@subs, $f, $basename, $head, $main, $description, $got_description, $x);

=pod

Get a list of the files in the perl common subs folder

=cut
  @subs = glob $sub_location . '*/*.pl';

  for ($x = 0; $x <= $#subs; $x++) {
    $f = $subs[$x];

=pod

Locate the pod_head and _main files for this subroutine. and get the description
We get the description from the pod_head.
e.g. file /Scripts/common/perl/beep.pl yields a $head value of /Scripts/common/perl/beep/beep_head.pl

=cut
    $basename = substr(basename($f), 0, -3);
    $head = $sub_location . $basename . '/' . $basename . "_head.pl";
    $main = $sub_location . $basename . '/' . $basename . "_main.pl";

=pod

If there is a _main.pl we create an entry in $$sub_hash_ptr with the _main.pl
file as the key.  We do this to avoid incorporating all the documentation that is
included in the assembled files in \Scripts\common\perl.

=cut
    if (-e $main) {
      $f = $main;
    }
    if (-e $head) {
      $got_description = 0;
      $description = "";
      open(INP, "<", $head) or die "Couldn't open $head in read mode: $!";
      while (<INP>) {
        if (/^=head[12] $basename/) {
          # Skip blank line following head1 declaration
          $_ = <INP>;
          $got_description = 1;
          next;
        }
        if ($got_description) {
          if (length($_) > 2) {
            chomp;
            $description .= " $_";
          }
          else { last; }
        }
      }
      close(INP);
      $f =~ s/\//\\/g;
      unless ($description) { $description = "No description available."; }
      $$sub_hash_ptr{ $f } = $description;
    }
  }
}


=pod

=head3 GetDateTime

=cut
sub GetDateTime {
  our ($d_ptr, $t_ptr, $date_fmt_spec, $date_sep_spec, $time_fmt_spec, $time_sep_spec) = @_;
  our ($d_fmt,         $t_fmt);
  our ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  unless ($date_fmt_spec) { $date_fmt_spec = 0; }
  unless ($date_sep_spec) { $date_sep_spec = '/'; }
  unless ($time_fmt_spec) { $time_fmt_spec = 0; }
  unless ($time_sep_spec) { $time_sep_spec = ':'; }

SWITCH1: {
    if ($date_fmt_spec == 0) {
      $d_fmt = "%02d" . $date_sep_spec . "%02d" . $date_sep_spec . "%04d";
      $$d_ptr = sprintf($d_fmt, $mday, $mon + 1, $year +1900);
      last SWITCH1;
    }
    if ($date_fmt_spec == 1) {
      $d_fmt = "%02d" . $date_sep_spec . "%02d" . $date_sep_spec . "%02d";
      $$d_ptr = sprintf($d_fmt, $mday, $mon + 1, $year - 100);
      last SWITCH1;
    }
    if ($date_fmt_spec == 2) {
      $d_fmt = "%02d" . $date_sep_spec . "%02d" . $date_sep_spec . "%04d";
      $$d_ptr = sprintf($d_fmt,  $mon + 1, $mday, $year + 1900);
      last SWITCH1;
    }
    if ($date_fmt_spec == 3) {
      $d_fmt = "%02d" . $date_sep_spec . "%02d" . $date_sep_spec . "%02d";
      $$d_ptr = sprintf($d_fmt, $mon + 1, $mday, $year - 100);
      last SWITCH1;
    }
    if ($date_fmt_spec == 4) {
      $d_fmt = "%04d" . $date_sep_spec . "%02d" . $date_sep_spec . "%02d";
      $$d_ptr = sprintf($d_fmt, $year + 1900, $mon + 1, $mday);
      last SWITCH1;
    }
    if ($date_fmt_spec == 5) {
      $d_fmt = "%02d" . $date_sep_spec . "%02d" . $date_sep_spec . "%02d";
      $$d_ptr = sprintf($d_fmt, $year - 100, $mon + 1, $mday);
      last SWITCH1;
    }
    # Default back to 0 if invalid parameter
    $date_fmt_spec = 0;
  } ## end SWITCH1:

SWITCH2: {
    if ($time_fmt_spec == 0) {
      $t_fmt = "%02d" . $time_sep_spec . "%02d";
      $$t_ptr = sprintf($t_fmt, $hour, $min);
      last SWITCH2;
    }
    if ($time_fmt_spec == 1) {
      $t_fmt = "%02d" . $time_sep_spec . "%02d" . $time_sep_spec . "%02d";
      $$t_ptr = sprintf($t_fmt, $hour, $min, $sec);
      last SWITCH2;
    }
    # Default back to 0 if invalid parameter
    $time_fmt_spec == 0;
  } ## end SWITCH2:
}