
=pod

=head1 Credits

Put some stuff here if you want to credit someone else.

=head1 Bugs

None, so far.

=head1 Support

Call John Staelens at ext (413) 743-7682 or text to (413) 212-3540.

=head1 Author

John Staelens

=head1 Change Log

  2016-05-26 -- Reorganized files to better separate code blocks, local subroutines and
                common subroutines in both this script and in the template files it will
                create.

  2016-05-27 -- Added 6 sets of fields to graphical interface for defining code blocks
                to be inserted into the mail file of the target template set.
                Added a cancel button to graphical interface for aborting template
                creation.

  2016-08-08 -- Added a capability to read a list of code blocks from a local file with
                the same name as the project with .blocks as the file name extension.

  2017-01-28 -- Fixed several errors in the GUI presentation.

  2018-05-01 -- Changed sub generate_makefile to set project_builder to
                /usr/local/bin/build_pl_linux.pl Changed copy of jpg files to conditionally
                copy only perlcamel.jpg and perlscript.jpg to $(project_base)
                Added runtime_base variable to Makefile to serve as location for completed
                runtime script, and added deployment rule to copy it there.
                Changed mk_perl_template_linux_pod_head.pl to indicate use of
                /usr/local/bin/mk_perl_template_linux.pl to perform template creation.

  2019-05-17 -- Modified makefile creation precedure to run fix for improperly created
                html documentation file.  Also to created a plain pod documentation file.

  2019-05-17 -- Modified sub generate_makefile to add to "deploy target" a check to see
                if deploy_dir has been declared.

  2019-05-18 -- Further modification to sub generate_makefile to streamline it and better
                document the make process.

  2019-05-23 -- Modifications to improve generated documentation file

  2019-06-08 -- Modified to restore capability of pre-defining code blocks through either
                the GUI interface or through the use of $(project).blocks text file.
=cut