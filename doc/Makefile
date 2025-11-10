# Makefile for LaTeX compilation

LATEX = pdflatex
BIBTEX = bibtex
RM = rm -f

# Main document name (without extension)
MAIN = midterm

# Source files
TEX_FILES = $(MAIN).tex
PDF_OUTPUT = $(MAIN).pdf

# Default target
all: $(PDF_OUTPUT)

# Compile LaTeX document
$(PDF_OUTPUT): $(TEX_FILES)
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)

# Alternative target with bibliography support (if needed later)
full: $(TEX_FILES)
	$(LATEX) $(MAIN)
	$(BIBTEX) $(MAIN) || true
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)

# Clean auxiliary files
clean:
	$(RM) $(MAIN).aux $(MAIN).log $(MAIN).out $(MAIN).toc
	$(RM) $(MAIN).bbl $(MAIN).blg $(MAIN).nav $(MAIN).snm
	$(RM) $(MAIN).vrb $(MAIN).dvi $(MAIN).fls $(MAIN).fdb_latexmk
	$(RM) $(MAIN).synctex.gz

# Clean everything including PDF
cleanall: clean
	$(RM) $(PDF_OUTPUT)

# View the PDF (Linux)
view: $(PDF_OUTPUT)
	xdg-open $(PDF_OUTPUT) &

# Continuous compilation with latexmk (if available)
watch:
	latexmk -pdf -pvc $(MAIN)

.PHONY: all full clean cleanall view watch