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
	install package/foren6.desktop.sample $(DESTDIR)/foren6.desktop
	echo "Icon=$$(readlink -f gui-qt/resources/logo/foren6-48-alpha.png)" >> $(DESTDIR)/foren6.desktop
	install gui-qt/release/foren6 $(DESTDIR)
	install capture/bin/lib* $(DESTDIR)
	install analyzer/dist/Debug/GNU-Linux-x86/lib* $(DESTDIR)

pre-package: submodules clean
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
