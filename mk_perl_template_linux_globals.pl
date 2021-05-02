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
