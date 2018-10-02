all: build open clean tarr
.PHONY: all clean tarr

latex_input = slides.tex
latex_output = slides.pdf

latex ?= pdflatex

latex_flags := --file_line_error

files := $(latex_input)
files += content.tex

img_directory := img
images := $(img_directory)/ls.pdf

aux_files := *.aux
all_deps := $(files)

tar_dest := /media/nicola/Drive/BackupTar/thesis3_slides.tar.bz2
gdrive_dest_dir := /home/nicola/GDrive
gdrive_dest_file := /home/nicola/GDrive/backs-tar/thesis3_slides.tar.bz2

$(latex_output): $(all_deps)
	$(latex) $(latex_flags) $(latex_input)
	$(latex) $(latex_flags) $(latex_input)

$(tar_dest): $(all_deps)
	tar -cjf $(tar_dest) $(PWD)
	test -d $(gdrive_dest_dir) && cp $(tar_dest) $(gdrive_dest_file)
	test -d $(gdrive_dest_dir) && ls -l $(gdrive_dest_file)

build: $(latex_output)

open:
	gvfs-open $(latex_output) 2> /dev/null &

tarr: $(tar_dest)

clean:
	rm -f $(aux_files)
	rm -f *.log
	rm -f *.toc
	rm -f *.out
	rm -f *.nav
	rm -f *.idx
	rm -f *.snm