html_src	:= $(wildcard doc/html/*)
lang_src	:= $(wildcard languages/*.po)

ifdef LANG
  LC	:= $(firstword $(subst ., ,$(LANG)))
else
  LC	:= en
endif

all : doc lang

doc : \
	$(html_src:doc/html/%.html=doc/txt/%.txt)
	
lang : \
	languages/$(LC).po \
	$(lang_src:languages/%.po=locale/%/LC_MESSAGES/pywws.mo)

# convert html documents to plain text
doc/txt/%.txt : doc/html/%.html
	links -dump -width 80 $< >$@

# compile a language file
locale/%/LC_MESSAGES/pywws.mo : languages/%.po
	mkdir -p $(dir $@)
	msgfmt --output-file=$@ $<

# create or update a language file from extracted strings
languages/$(LC).po : languages/pywws.pot
	if [ -e $@ ]; then \
	  cd $(dir $<) ; \
	  msgmerge $(notdir $@ $<) --update ; \
	else \
	  msginit --input=$< --output=- --locale=$(LC) | \
	  sed 's/PACKAGE/pywws/' | sed 's/ VERSION//' >$@ ; \
	fi

# extract marked strings from Python files
languages/pywws.pot :
	xgettext --language=Python --output=- \
		--copyright-holder="Jim Easterbrook" \
		--msgid-bugs-address="jim@jim-easterbrook.me.uk" \
		*.py pywws/*.py | \
	sed 's/PACKAGE VERSION/pywws/' >$@