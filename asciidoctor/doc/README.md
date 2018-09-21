Scibian asciidoctor templates
=============================

Install asciidoctor and the template package:

 # apt-get install asciidoctor asciidoctor-scibian-tpl

= Scibian guide

Bootstrap a Scibian guide using one of the provided example:

 $ cp -r /usr/share/doc/asciidoctor-scibian-tpl/examples/scibian/guide newguide/

Edit metadata.yaml and write document.

And finally build HTML and PDF outputs:

 $ make
