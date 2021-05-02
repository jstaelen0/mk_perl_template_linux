#--------------------------------------------------------------------------------------------------#
# This Makefile was created on 11/15/2020 at 14:06 using following command:                        #
#                                                                                                  #
# perl /usr/local/bin/generate_makefile.pl /media/HGST8TB/linux-shared/Scripts/DevelopmentTools/mk_perl_template_linux/source mk_perl_template_linux .pl /usr/local/bin 0                                                                      #
#--------------------------------------------------------------------------------------------------#

#===> Create simple variable assignment section.
project         = mk_perl_template_linux
SHELL           := /bin/bash
project_ext     = .pl
base            = /media/HGST8TB/linux-shared/Scripts/DevelopmentTools
common_source   = /media/HGST8TB/linux-shared/Scripts/common/perl
#===> Set debugging to 0 to get production version of program
debugging       = 0

#===> Create simple variable assignment section.
project_target  = $(project)$(project_ext)
project_base    = $(base)/$(project)
project_source  = $(project_base)/source
parts           = $(project_source)/$(project).parts

usage_implementation_file = $(project_source)/implementation.txt
usage_synopsis_file       = $(project_source)/synopsis.txt

#===> Complete the following if you wish to make use of the Makefile's deploy target
#===> (typically, set it to /usr/local/bin)
deploy_dir      = /usr/local/bin
ifeq '$(project_ext)' '.pl'
  doc_dir = /var/www/athome.net/public_html/scriptdocs/site-perl
endif
ifeq '$(project_ext)' '.sh'
  doc_dir = /var/www/athome.net/public_html/scriptdocs/site-bash
endif

icon_dir        = /usr/share/icons
runtime_base    = /usr/local/bin
project_builder = $(runtime_base)/build_pl_linux.pl

#===> # Declare the names of the parts      files that will be combined the target.
sources	= $(project_source)/$(project)_pod_head.pl \
	$(project_source)/$(project)_globals.pl \
	$(project_source)/$(project)_main.pl \
	$(project_source)/$(project)_gui.pl \
	$(project_source)/$(project)_subroutines.pl \
	$(project_source)/$(project)_mk_debian_desktop_shortcut.pl \
	$(project_source)/$(project)_linux_special_folders.pl \
	$(project_source)/$(project)_get_list_of_common_perl_subroutines.pl \
	$(common_source)/GetDateTime/GetDateTime_main.pl \

all :
	make $(project_target)
	@echo
	make docs
	make deploy
	@echo
ifeq '$(debugging)' '1'
	make show_make_vars
else
	@echo Not Showing make variables since debugging is turned off.
endif

#===> The rules to build primary target.
$(project_target) : $(sources) $(parts) $(project_source)/Makefile
	@if [[ -f $(project_target) ]]; then sudo rm $(project_target); fi
	@sudo perl $(project_builder) $(parts) $(project_source)/$(project_target) $(debugging) $(debugging)
	#@if [ -f $(project_source)/$(project_target) ] ; then sudo cp -f $(project_source)/$(project_target) $(project_base) ; fi
	#@if [ -f $(project_source)/$(project).ico ] ; then sudo cp -f $(project_source)/$(project).ico $(project_base) ; fi
	@if [ -f $(icon_dir)/perlscript.jpg ] ; then convert $(icon_dir)/perlscript.jpg $(project_base)/$(project).ico ; fi
	@if [[ -f $(project_target) ]]; then sudo chmod -w $(project_target); fi

#===> Add rule to generate the .parts      inventory file needed by build_pl_linux.pl when assembling the target script.
$(parts) : $(sources) $(project_source)/Makefile
	@if [ -f $(parts) ] ; then sudo rm -f $(parts) ; fi
	@for part in $(sources) ; do echo $$part >> $(parts) ; done

$(project_source)/$(project)_sub_usage.pl : $(usage_implementation_file) $(usage_synopsis_file)
	perl $(deploy_dir)/generate_sub_usage.pl \
	--script_type="perl" \
	--source_dir=`pwd` \
	--synopsis_text="$(usage_synopsis_file)" \
	--parameter_list="target_directory target_name target_ext deploy_dir debugging doc_dir" \
	--implementation="$(usage_implementation_file)"

#===> Add  rules to generate documentation files.
docs : $(project_target)
ifeq '$(project_ext)' '.pl'
	@perltidy -html -pod -toc $(project_source)/$(project_target)
	@rm pod2htmd.tmp
endif
ifeq '$(project_ext)' '.sh'
	@vim -c ":TOhtml" -c ":w" -c ":qall" $(project_target)
endif
	#@cp -f *.html $(project_base)
	@gnuhtml2latex $(project_target).html
	@cp $(project_target).tex temp.tex
	@perl -pe "s/\x5C\x24/\x24/g" temp.tex > temp2.tex
	@perl -pe "s/-\x24\x5C,\x24/-/g" temp2.tex > $(project_target).tex
	@-pdflatex -interaction=nonstopmode -max-print-line=120 "$(project_target).tex" &> /dev/null
	@-rm $(project_target).aux $(project_target).log
	@rm temp.tex temp2.tex
	#xreader $(project_target).pdf

#===> Generate code to show the makefile variables.
.PHONY : show_make_vars
show_make_vars :
	@echo ""
	@echo "Makefile Variables:"
	@echo ""
	@echo "project-----------: $(project)"
	@echo "project_ext-------; $(project_ext)"
	@echo "base--------------: $(base)"
	@echo "common_source-----: $(common_source)"
	@echo "project_target----: $(project_target)"
	@echo "project_base------: $(project_base)"
	@echo "project_source----: $(project_source)"
	@echo "parts     --------: $(parts)"
	@echo "deploy_dir--------: $(deploy_dir)"
	@echo "doc_dir-----------: $(doc_dir)"
	@echo "runtime_base------: $(runtime_base)"
	@echo ""

#===> Add a rule to test the script.
test : $(project_target)
	@perl -d $(project_target) [params]

#===> Add a deploy rule.
deploy: $(project_target)
	@if [ ! $(deploy_dir) ] ; then echo deploy_dir not declared in this makefile ; exit 1; fi
	@if [ -f $(project_source)/$(project_target) ] ; then sudo cp -f $(project_source)/$(project_target) $(deploy_dir)/$(project_target) ; fi
	@echo $(project_source)/$(project_target) deployed to $(deploy_dir)/$(project_target)
	@if [ -f $(project_source)/$(project_target).html ] ; then sudo cp $(project_source)/$(project_target).html $(doc_dir)/ ; fi
	@if [ -f $(project_source)/$(project_target).jpg ]; then -sudo cp -f $(project_source)/$(project_target).jpg $(doc_dir)/ ; fi
	@if [ -f $(project_source)/$(project_target).png ]; then -sudo cp -f $(project_source)/$(project_target).png $(doc_dir)/ ; fi
	@echo $(project_source)/$(project_target).html deployed to $(doc_dir)
