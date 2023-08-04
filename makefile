TEXMFDIST = $(shell kpsewhich -var-value=TEXMFDIST)
BIN_DIR ?= /usr/bin
ETC_DIR ?= /etc
template_PATH ?= /usr/share/pandoc/user-templates

all:

pre:
	git submodule init
	git submodule update

test: pre rst2arb.conf rst2arb.py
	bash ./test.sh all

install: pre rst2arb.py rst2arb.conf
	install -Dm755 rst2arb.py $(DESTDIR)$(BIN_DIR)/rst2arb
	install -Dm644 rst2arb.conf $(DESTDIR)$(ETC_DIR)/rst2arb.conf
	sed -i "s|\(^template.*= \)./\(latex-cjk.tex\)|\1$(template_PATH)/\2|" \
		$(DESTDIR)$(ETC_DIR)/rst2arb.conf
	sed -i "s|\(^template.*= \)./\(eisvogel-v2.4.0.tex\)|\1$(template_PATH)/\2|" \
		$(DESTDIR)$(ETC_DIR)/rst2arb.conf
	sed -i "s|\(SYSTEM_CONF.*=.*\)/etc/\(rst2arb.conf.*\)|\1$(ETC_DIR)/\2|" \
		$(DESTDIR)$(BIN_DIR)/rst2arb
	find latex/ -name '*.sty' -exec install -Dm644 {} $(DESTDIR)/$(TEXMFDIST)/tex/{} \;
	install -Dm644 latex-cjk.tex $(DESTDIR)/$(template_PATH)/latex-cjk.tex
	install -Dm644 eisvogel-v2.4.0.tex $(DESTDIR)/$(template_PATH)/eisvogel-v2.4.0.tex

clean:
	-rm -r cache/*

.PHONY : pre test install clean 
