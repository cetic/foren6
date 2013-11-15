QMAKE_QT4=qmake-qt4
MODE:=release

all: submodules check-tshark build setup-capture-links

submodules:
	git submodule init
	git submodule update

check-tshark:
        #ugly HACK
	@if [ "$$(which tshark)0" = "0" ]; then \
	    echo "tshark must be installed in order to use this tool."; \
	    exit 1; \
	fi

build:
	mkdir -p analyzer/build
	cd analyzer/build && cmake .. -DCMAKE_BUILD_TYPE=$(MODE) && $(MAKE)
	mkdir -p capture/build
	cd capture/build && cmake .. -DCMAKE_BUILD_TYPE=$(MODE) && $(MAKE)
	cd gui-qt && $(QMAKE_QT4) foren6.pro && $(MAKE) $(MODE)

setup-capture-links:
	mkdir -p gui-qt/$(MODE)
	-rm gui-qt/$(MODE)/capture 2>&1 > /dev/null

	#link target is relative to link location
	ln -s ../../capture/bin gui-qt/$(MODE)/capture

clean:
	rm -rf analyzer/build
	rm -rf capture/build
	cd gui-qt && $(MAKE) clean

run: all
	cd gui-qt && LD_LIBRARY_PATH=../analyzer/dist/Debug/GNU-Linux-x86 $(MODE)/foren6

install: install-linux

install-linux:
	install -d $(DESTDIR)/usr/share/applications
	install package/foren6.desktop.sample $(DESTDIR)/usr/share/applications/foren6.desktop
	install -d $(DESTDIR)/bin
	install gui-qt/release/foren6 $(DESTDIR)/bin
	install -d $(DESTDIR)/usr/lib/foren6/interfaces
	install capture/bin/lib* $(DESTDIR)/usr/lib/foren6/interfaces
	install analyzer/dist/Debug/GNU-Linux-x86/lib* $(DESTDIR)/usr/lib
	install -d $(DESTDIR)/usr/share/doc/foren6/layouts
	install -d $(DESTDIR)/usr/share/doc/foren6/pcaps
	install -d $(DESTDIR)/usr/share/doc/foren6/icons
	install package/foren6-48-alpha.png $(DESTDIR)/usr/share/doc/foren6/icons
	install examples/layouts/* $(DESTDIR)/usr/share/doc/foren6/layouts
	install examples/pcaps/* $(DESTDIR)/usr/share/doc/foren6/pcaps

pre-package: submodules
	cd gui-qt && $(QMAKE_QT4) foren6.pro && $(MAKE) clean

help:
	@echo "Usage: $(MAKE) [ MODE=<mode> ] <target> [ <target> ... ]"
	@echo "Where:"
	@echo "    <mode> is either debug or release (default is debug)"
	@echo "    <target> is one or more of these:"
	@echo " all  : compile all projects. You can set MODE to debug or release (default is debug)"
	@echo " clean : clean all projects"
	@echo " run   : run the LoWPAN Dianosis Tool"

.PHONY: all clean run help
