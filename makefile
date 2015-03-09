local_TEXMFHOME = ./texmf
TEXMFHOME = $(shell kpsewhich -var-value=TEXMFDIST)
INSTALL_DIR = $(TEXMFDIST)/tex/latex

rst2arb:

pre:
	git submodule init
	git submodule update
	find latex/ -name '*.sty' -exec install -Dm644 {} $(local_TEXMFHOME)/tex/{} \;

test: pre
	bash ./test.sh all

install: pre


clean:
	-rm cache/test*.pdf
	-rm -r $(local_TEXMFHOME)


.PHONY : pre test install clean 
