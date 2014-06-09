/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <QtWidgets>
#include <stdio.h>
#include <string.h>

#include "biquad_controls.h"
#include "window.h"
#include "xscope_host_shared.h"

extern int g_sockfd;

Window::Window()
{
    biquadSliders = new BiquadControls(tr("Biquads"), this);

    stackedWidget = new QStackedWidget;
    stackedWidget->addWidget(biquadSliders);

    createControls(tr("Controls"));

    QHBoxLayout *layout = new QHBoxLayout;
    layout->addWidget(controlsGroup);
    layout->addWidget(stackedWidget);
    setLayout(layout);

    setWindowTitle(tr("Sliders"));
}

void Window::createControls(const QString &title)
{
    // BIQUADS
    biquadControls = new QGroupBox(tr("BiQuads"));
    QBoxLayout *biquadLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    biquadEnable = new QCheckBox(tr("Enable"));
    connect(biquadEnable, SIGNAL(toggled(bool)),
            this, SLOT(enableBiquads(bool)));

    selectAll = new QPushButton(tr("Select All"));
    connect(selectAll, SIGNAL(pressed()),
            biquadSliders, SLOT(selectAll()));

    selectNone = new QPushButton(tr("Select None"));
    connect(selectNone, SIGNAL(pressed()),
            biquadSliders, SLOT(selectNone()));

    biquadLayout->addWidget(biquadEnable);
    biquadLayout->addWidget(selectAll);
    biquadLayout->addWidget(selectNone);
    biquadControls->setLayout(biquadLayout);


    // DRC
    drcControls = new QGroupBox(tr("DRC"));
    QBoxLayout *drcLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    drcEnable = new QCheckBox(tr("Enable"));
    connect(drcEnable, SIGNAL(toggled(bool)),
            this, SLOT(enableDrc(bool)));
    drcLayout->addWidget(drcEnable);
    drcControls->setLayout(drcLayout);


    // GAIN
    controlsGroup = new QGroupBox(title);

    preGainLabel = new QLabel(tr("Pre Amp"));

    preGainDial = new QDial;
    preGainDial->setRange(0, 100);
    preGainDial->setSingleStep(1);
    preGainDial->setValue(0);
    connect(preGainDial, SIGNAL(valueChanged(int)),
            this, SLOT(setPreGain(int)));

    gainLabel = new QLabel(tr("Gain"));

    gainDial = new QDial;
    gainDial->setRange(0, 100);
    gainDial->setSingleStep(1);
    gainDial->setValue(100);
    connect(gainDial, SIGNAL(valueChanged(int)),
            this, SLOT(setGain(int)));

    QGridLayout *controlsLayout = new QGridLayout;
    controlsLayout->addWidget(preGainDial, 0, 0);
    controlsLayout->addWidget(preGainLabel, 1, 0);
    controlsLayout->addWidget(gainDial, 0, 1);
    controlsLayout->addWidget(gainLabel, 1, 1);
    controlsLayout->addWidget(biquadControls, 0, 2);
    controlsLayout->addWidget(drcControls, 1, 2);
    controlsGroup->setLayout(controlsLayout);
}

#define MAX_COMMAND_LEN 100

const std::string commands[] = {
    "e b",
    "d b",
    "e d",
    "d d",
};

typedef enum {
    COMMAND_ENABLE_BIQUADS = 0,
    COMMAND_DISABLE_BIQUADS,
    COMMAND_ENABLE_DRC,
    COMMAND_DISABLE_DRC,
} CommandIds;

void Window::enableBiquads(bool enable)
{
    const char *cmd;
    if (enable) {
        cmd = commands[COMMAND_ENABLE_BIQUADS].c_str();
    } else {
        cmd = commands[COMMAND_DISABLE_BIQUADS].c_str();
    }
    xscope_ep_request_upload(g_sockfd, strlen(cmd), (const unsigned char *)cmd);
}

void Window::enableDrc(bool enable)
{
    const char *cmd;
    if (enable) {
        cmd = commands[COMMAND_ENABLE_DRC].c_str();
    } else {
        cmd = commands[COMMAND_DISABLE_DRC].c_str();
    }
    xscope_ep_request_upload(g_sockfd, strlen(cmd), (const unsigned char *)cmd);
}

void Window::setPreGain(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "p %d", value);
    size_t len = strlen(cmd) + 1;
    xscope_ep_request_upload(g_sockfd, len, (const unsigned char *)cmd);
}

void Window::setGain(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "g %d", value);
    size_t len = strlen(cmd) + 1;
    xscope_ep_request_upload(g_sockfd, len, (const unsigned char *)cmd);
}

void Window::setBiquadBank(int index, int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "b a %d %d", index, value);
    size_t len = strlen(cmd) + 1;
    xscope_ep_request_upload(g_sockfd, len, (const unsigned char *)cmd);
}
