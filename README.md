Top-level project for the 6LoWPAN Diagnosis Tool.
To get started:

    git clone https://github.com/cetic/foren6.git
    cd foren6
    git submodule init
    git submodule update
    make

On MACOS-X with Fink, run the following command :
    make QMAKE_QT4=/sw/lib/qt4-mac/bin/qmake CFLAGS=-m32
