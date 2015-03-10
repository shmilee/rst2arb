local_TEXMFHOME = ./texmf
TEXMFDIST = $(shell kpsewhich -var-value=TEXMFDIST)
template_PATH = /usr/share/pandoc/templates/

rst2arb: rst2arb.sh
	sed -e's|##TPATH##|$(template_PATH)|' $< >$@

pre:
	git submodule init
	git submodule update

test: pre
	find latex/ -name '*.sty' -exec install -Dm644 {} $(local_TEXMFHOME)/tex/{} \;
	bash ./test.sh all

install: pre
	install -Dm755 rst2arb $(DESTDIR)/usr/bin/rst2arb
	find latex/ -name '*.sty' -exec install -Dm644 {} $(DESTDIR)/$(TEXMFDIST)/tex/{} \;
	install -Dm644 beamer-cjk.tex $(DESTDIR)/$(template_PATH)/beamer-cjk.tex
	install -Dm644 latex-cjk.tex $(DESTDIR)/$(template_PATH)/latex-cjk.tex

clean:
	-rm rst2arb
	-rm cache/test*.pdf
	-rm -r $(local_TEXMFHOME)


.PHONY : pre test install clean 
