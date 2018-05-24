.SUFFIXES:

.PHONY: install uninstall

PREFIX ?= $(HOME)/.local
dest = $(DESTDIR)$(PREFIX)
bindir = $(dest)/bin
mandir = $(dest)/share/man/man1
compldir = $(dest)/share/bash-completion/completions
bin = rg
manpage = $(bin).1
compl = $(bin).bash

install: $(manpage)
	install -d $(bindir) $(mandir)
	install -m 0775 $(bin) $(bindir)
	install -m 0644 $(manpage) $(mandir)
	install -m 0644 $(compl) $(compldir)

uninstall:
	$(RM) $(bindir)/$(bin)
	$(RM) $(mandir)/$(manpage)
	$(RM) $(compldir)/$(compl)
