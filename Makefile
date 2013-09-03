QMAKE_QT4=qmake-qt4

all:
	mkdir -p analyzer/build
	cd analyzer/build && cmake .. && $(MAKE)
	mkdir -p capture/build
	cd capture/build && cmake .. && $(MAKE)
	cd gui-qt && $(QMAKE_QT4) rpl_diagnosis_tool.pro && $(MAKE) debug

clean:
	rm -rf analyzer/build
	rm -rf capture/build
	cd gui-qt && $(MAKE) clean
