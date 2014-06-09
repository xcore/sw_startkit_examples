QT += widgets

HEADERS     = \
              window.h \
    mutex.h \
    queues.h \
    xscope_host_shared.h \
    biquad_slider.h \
    biquad_controls.h
SOURCES     = main.cpp \
              window.cpp \
    mutex.c \
    queues.c \
    xscope_host_shared.c \
    biquad_controls.cpp \
    biquad_sliders.cpp

# install
target.path = $$[QT_INSTALL_EXAMPLES]/widgets/widgets/sliders
INSTALLS += target
