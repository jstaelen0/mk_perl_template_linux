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
