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
    }

    for (int i = 0; i < NUM_BIQUADS; i++) {
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

void BiquadControls::invertSelection()
{
    for (int i = 0; i < NUM_BIQUADS; i++) {
        if (m_controls[i]->isChecked())
            m_controls[i]->setSelected(false);
        else
            m_controls[i]->setSelected(true);
    }
}

void BiquadControls::selectionChanged(bool selected)
{
    for (int i = 0; i < NUM_BIQUADS; i++) {
        disconnect(m_controls[i], SIGNAL(valueChanged(int)), 0, 0);
    }
    for (int i = 0; i < NUM_BIQUADS; i++) {
        for (int j = 0; j < NUM_BIQUADS; j++) {
            if (i == j || !m_controls[j]->isChecked())
                continue;

            connect(m_controls[i], SIGNAL(valueChanged(int)), m_controls[j], SLOT(setValue(int)));
        }
    }
}

bool BiquadControls::allSelected()
{
    bool allSelected = true;
    for (int i = 0; i < NUM_BIQUADS && allSelected; i++) {
        if (!m_controls[i]->isChecked())
            allSelected = false;
    }
    return allSelected;
}
