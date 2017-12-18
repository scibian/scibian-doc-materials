GENERATOR=/usr/lib/asciidoctor/scibian/exec/gen-base-guide
TEMPLATE=/usr/share/asciidoctor/scibian/guide
DOCTYPE=book
SRC=main.asc $(shell find src -name '*.asc')
NAME=$(shell $(GENERATOR) --doc-name)

IMG_DIR=img
IMG_SVG=$(wildcard $(IMG_DIR)/*.svg)
IMG_PDF=$(patsubst %.svg,%.pdf,$(IMG_SVG))
IMG_PNG=$(patsubst %.svg,%.png,$(IMG_SVG))

all: html pdf

html: $(NAME).html

$(NAME).html: base.asc $(SRC) $(IMG_PNG)
	asciidoctor --doctype $(DOCTYPE) --attribute data-uri --backend html5 --out-file $@ base.asc

pdf: $(NAME).pdf

base.asc: metadata.yaml
	$(GENERATOR) --render-base

$(NAME).pdf: base.asc $(SRC) $(IMG_PDF)
	asciidoctor --doctype $(DOCTYPE) --template-dir $(TEMPLATE) --backend latex --out-file $(@:.pdf=.tex) base.asc
	rubber --pdf $(@:.pdf=.tex)

$(IMG_DIR)/%.pdf: **/%.svg
	inkscape --export-pdf=$@ -D $<

$(IMG_DIR)/%.png: **/%.svg
	inkscape --export-png=$@ -D $<

clean:
	-rubber --clean $(MAIN:.asc=.tex)
	-rm -f *.html *.tex *.pdf base.asc $(IMG_PDF) $(IMG_PNG) $(NAME).*
