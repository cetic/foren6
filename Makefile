QMAKE_QT4=qmake-qt4
MODE:=debug

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
	mkdir -p bin
	rm -f bin/run-foren6
	echo "#!/bin/bash" >> bin/run-foren6
	echo "LD_LIBRARY_PATH=$$(pwd)/analyzer/dist/Debug/GNU-Linux-x86 $$(pwd)/gui-qt/release/foren6" >> bin/run-foren6
	chmod +x bin/run-foren6
	ln -sf $$(readlink -f bin/run-foren6) /usr/bin/foren6
	cp package/foren6.desktop.sample package/foren6.desktop
	echo "Icon=$$(readlink -f gui-qt/resources/logo/foren6-48-alpha.png)" >> package/foren6.desktop
	sudo mv package/foren6.desktop /usr/share/applications

help:
	@echo "Usage: $(MAKE) [ MODE=<mode> ] <target> [ <target> ... ]"
	@echo "Where:"
	@echo "    <mode> is either debug or release (default is debug)"
	@echo "    <target> is one or more of these:"
	@echo " all  : compile all projects. You can set MODE to debug or release (default is debug)"
	@echo " clean : clean all projects"
	@echo " run   : run the LoWPAN Dianosis Tool"

.PHONY: all clean run help
