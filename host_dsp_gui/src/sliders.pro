QT += widgets printsupport

HEADERS     = \
              window.h \
    mutex.h \
    queues.h \
    xscope_host_shared.h \
    biquad_slider.h \
    biquad_controls.h \
    drc_controls.h \
    qcustomplot.h \
    drc_spinbox.h
SOURCES     = main.cpp \
              window.cpp \
    mutex.c \
    queues.c \
    xscope_host_shared.c \
    biquad_controls.cpp \
    biquad_sliders.cpp \
    drc_controls.cpp \
    qcustomplot.cpp \
    drc_spinbox.cpp

# install
target.path = $$[QT_INSTALL_EXAMPLES]/widgets/widgets/sliders
INSTALLS += target
