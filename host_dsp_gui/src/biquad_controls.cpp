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

#include "biquad_controls.h"
#include "biquad_slider.h"

const QString bank_title[NUM_BIQUADS] = {
    "Low Pass",
    "125 Hz",
    "250 Hz",
    "500 Hz",
    "1 kHz",
    "2 kHz",
    "4 kHz",
    "6 kHz",
    "8kHz",
    "High Pass",
};

BiquadControls::BiquadControls(const QString &title, QWidget *parent)
    : QGroupBox(title, parent)
{
    QBoxLayout *slidersLayout = new QBoxLayout(QBoxLayout::LeftToRight);
    for (int i = 0; i < NUM_BIQUADS; i++) {
        m_controls[i] = new BiquadSlider(bank_title[i], i, this);
        slidersLayout->addWidget(m_controls[i]);
    }

    for (int i = 0; i < NUM_BIQUADS; i++) {
        for (int j = 0; j < NUM_BIQUADS; j++) {
            if (i == j)
                continue;
            connect(m_controls[i], SIGNAL(valueChanged(int)), m_controls[j], SLOT(setValue(int)));
        }
        connect(m_controls[i], SIGNAL(valueChanged(int, int)), parent, SLOT(setBiquadBank(int, int)));
    }

    setLayout(slidersLayout);
}

void BiquadControls::selectAll()
{
    for (int i = 0; i < NUM_BIQUADS; i++) {
        m_controls[i]->setSelected(true);
    }
}

void BiquadControls::selectNone()
{
    for (int i = 0; i < NUM_BIQUADS; i++) {
        m_controls[i]->setSelected(false);
    }
}
