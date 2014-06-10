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
#include "drc_controls.h"
#include "window.h"
#include "xscope_host_shared.h"
#include "queues.h"

Window::Window()
{
    createBiquadControls();
    createDrcControls();
    createControls();

    QGridLayout *layout = new QGridLayout();
    layout->addWidget(m_preGainBox, 0, 0);
    layout->addWidget(m_biquadControlBox, 0, 1);
    layout->addWidget(m_gainBox, 1, 0);
    layout->addWidget(m_drcControlBox, 1, 1);
    setLayout(layout);

    setWindowTitle(tr("DSP Control"));
}

void Window::createBiquadControls()
{
    // BIQUADS
    m_biquadSliders = new BiquadControls(NULL, this);

    m_biquadControlBox = new QGroupBox(tr("Biquads"));
    QBoxLayout *topLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    m_biquadEnable = new QCheckBox(tr("Enable"));
    connect(m_biquadEnable, SIGNAL(toggled(bool)), this, SLOT(enableBiquads(bool)));

    m_selectAll = new QPushButton(tr("Select all"));
    connect(m_selectAll, SIGNAL(pressed()), m_biquadSliders, SLOT(selectAll()));

    m_selectNone = new QPushButton(tr("Select none"));
    connect(m_selectNone, SIGNAL(pressed()), m_biquadSliders, SLOT(selectNone()));

    m_selectInvert = new QPushButton(tr("Invert selection"));
    connect(m_selectInvert, SIGNAL(pressed()), m_biquadSliders, SLOT(invertSelection()));

    QBoxLayout *controlsLayout = new QBoxLayout(QBoxLayout::LeftToRight);
    controlsLayout->addWidget(m_biquadEnable);
    controlsLayout->addWidget(m_selectAll);
    controlsLayout->addWidget(m_selectNone);
    controlsLayout->addWidget(m_selectInvert);

    QGroupBox *controls = new QGroupBox();
    controls->setLayout(controlsLayout);

    topLayout->addWidget(controls);
    topLayout->addWidget(m_biquadSliders);
    m_biquadControlBox->setLayout(topLayout);
}

void Window::createDrcControls()
{
    // DRC
    m_drcControlBox = new QGroupBox(tr("DRC"));
    QBoxLayout *drcLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    DrcControls *drcControls = new DrcControls(NULL, this);

    m_drcEnable = new QCheckBox(tr("Enable"));
    connect(m_drcEnable, SIGNAL(toggled(bool)), this, SLOT(enableDrc(bool)));
    drcLayout->addWidget(m_drcEnable);
    drcLayout->addWidget(drcControls);
    m_drcControlBox->setLayout(drcLayout);
}

void Window::createControls()
{
    // GAIN
    m_preGainBox = new QGroupBox(tr("Pre Amp"));
    QBoxLayout *preGainLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    m_preGainDial = new QDial;
    m_preGainDial->setRange(0, 100);
    m_preGainDial->setSingleStep(1);
    m_preGainDial->setValue(0);
    connect(m_preGainDial, SIGNAL(valueChanged(int)), this, SLOT(setPreGain(int)));

    m_preGainSpinBox = new QSpinBox;
    m_preGainSpinBox->setRange(0, 100);
    m_preGainSpinBox->setSingleStep(1);
    m_preGainSpinBox->setValue(0);

    connect(m_preGainDial, SIGNAL(valueChanged(int)), m_preGainSpinBox, SLOT(setValue(int)));
    connect(m_preGainSpinBox, SIGNAL(valueChanged(int)), m_preGainDial, SLOT(setValue(int)));

    preGainLayout->addWidget(m_preGainDial);
    preGainLayout->addWidget(m_preGainSpinBox);
    m_preGainBox->setLayout(preGainLayout);

    m_gainBox = new QGroupBox(tr("Gain"));
    QBoxLayout *gainLayout = new QBoxLayout(QBoxLayout::TopToBottom);

    m_gainDial = new QDial;
    m_gainDial->setRange(0, 100);
    m_gainDial->setSingleStep(1);
    m_gainDial->setValue(100);
    connect(m_gainDial, SIGNAL(valueChanged(int)), this, SLOT(setGain(int)));

    m_gainSpinBox = new QSpinBox;
    m_gainSpinBox->setRange(0, 100);
    m_gainSpinBox->setSingleStep(1);
    m_gainSpinBox->setValue(100);

    connect(m_gainDial, SIGNAL(valueChanged(int)), m_gainSpinBox, SLOT(setValue(int)));
    connect(m_gainSpinBox, SIGNAL(valueChanged(int)), m_gainDial, SLOT(setValue(int)));

    gainLayout->addWidget(m_gainDial);
    gainLayout->addWidget(m_gainSpinBox);
    m_gainBox->setLayout(gainLayout);
}

void Window::enableBiquads(bool enable)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "%s b", enable ? "e" : "d");
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::enableDrc(bool enable)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "%s d", enable ? "e" : "d");
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setPreGain(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "p %d", value);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setGain(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "g %d", value);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setBiquadBank(int index, int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    if (m_biquadSliders->allSelected())
        sprintf(&cmd[0], "b a a %d", value);
    else
        sprintf(&cmd[0], "b a %d %d", index, value);

    // Prevent too many commands being sent
    if (queue_empty(g_sockfd))
        xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setLevelAttack(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "a a %d", value);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setLevelRelease(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "r a %d", value);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}

void Window::setLevelThreshold(int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "l a %d", value);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);
}
