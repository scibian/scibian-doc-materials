SRC                       ?= main.asc $(shell find src -name '*.asc')
NAME                      := $(shell $(GENERATOR) --doc-name)

IMG_DIR                   ?= img
PNG_DPI                   ?= 192
IMG_SVG                   := $(wildcard $(IMG_DIR)/*.svg)
IMG_PDF                   := $(patsubst %.svg,%.pdf,$(IMG_SVG))
IMG_PNG                   := $(patsubst %.svg,%.png,$(IMG_SVG))

PDF_THEME_DIR             ?= /usr/share/asciidoctor/scibian/themes
PDF_LEGACY_TPL_COMMON_DIR := /usr/share/asciidoctor/scibian/common
PDF_SOURCE_HIGHLIGHTER    ?= rouge
PDF_OPTS                  ?=
HTML_SOURCE_HIGHLIGHTER   ?= pygments
HTML_OPTS                 ?=

all: html pdf

html: $(NAME).html

$(NAME).html: base.asc $(SRC) $(IMG_PNG)
	asciidoctor --doctype $(DOCTYPE) \
	            --attribute data-uri \
	            --attribute source-highlighter=$(HTML_SOURCE_HIGHLIGHTER) \
	            --backend html5 \
	            $(HTML_OPTS) --out-file $@ base.asc

pdf: $(NAME).pdf

base.asc: metadata.yaml
	$(GENERATOR) --render-base

$(NAME).pdf: base.asc $(SRC) $(IMG_PDF)
ifeq ($(PDF_LEGACY),yes)
	asciidoctor --doctype $(DOCTYPE) \
	            --template-dir $(PDF_LEGACY_TPL_COMMON_DIR) \
	            --template-dir $(PDF_LEGACY_TPL_DOC_DIR) \
	            --backend latex \
	            --out-file $(@:.pdf=.tex) base.asc
	rubber --pdf $(@:.pdf=.tex)
else
	# create tmp build dir
	$(eval TMP_BUILD_D := $(shell mktemp -d))	
	# copy document sources in tmp build dir
	cp -r * $(TMP_BUILD_D)

	# replace SVG images with PNG
	find $(TMP_BUILD_D) -type f -exec sed -i 's/^\(image::.*\)\.svg\(.*\)/\1.png\2/' {} \;
	
	# build PDF using asciidoctor-pdf
	asciidoctor --doctype $(DOCTYPE) \
	            --out-file $@ \
	            --require asciidoctor-pdf \
	            --backend pdf \
	            --attribute pdf-stylesdir=$(PDF_THEME_DIR) \
	            --attribute pdf-style=$(PDF_STYLE) \
	            --attribute source-highlighter=$(PDF_SOURCE_HIGHLIGHTER) \
	            $(PDF_OPTS) $(TMP_BUILD_D)/base.asc

	# delete tmp build dir
	rm -rf $(TMP_BUILD_D)
endif

$(IMG_DIR)/%.pdf: $(IMG_DIR)/%.svg
	inkscape --export-pdf=$@ -D $<

$(IMG_DIR)/%.png: $(IMG_DIR)/%.svg
	inkscape --export-png=$@ --export-dpi=$(PNG_DPI) -D $<

clean:
	-rm -f *.html *.pdf base.asc $(IMG_PDF) $(IMG_PNG) $(NAME).*
