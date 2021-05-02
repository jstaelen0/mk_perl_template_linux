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