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