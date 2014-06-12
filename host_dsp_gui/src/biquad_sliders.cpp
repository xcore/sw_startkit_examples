#include <QtWidgets>

#include "biquad_slider.h"

#define SLIDER_MIN 0
#define SLIDER_MAX 24
#define SLIDER_INITIAL 20

BiquadSlider::BiquadSlider(const QString &title, int index, QWidget *parent)
    : QGroupBox(title, parent)
    , m_index(index)
{
    m_slider = new QSlider(Qt::Vertical);
    m_slider->setFocusPolicy(Qt::StrongFocus);
    m_slider->setTickPosition(QSlider::TicksBothSides);
    m_slider->setTickInterval(10);
    m_slider->setSingleStep(1);
    m_slider->setMinimum(SLIDER_MIN);
    m_slider->setMaximum(SLIDER_MAX);
    m_slider->setValue(SLIDER_INITIAL);

    m_valueSpinBox = new QSpinBox;
    m_valueSpinBox->setRange(SLIDER_MIN, SLIDER_MAX);
    m_valueSpinBox->setSingleStep(1);
    m_valueSpinBox->setValue(SLIDER_INITIAL);

    m_selected = new QCheckBox;
    m_selected->setChecked(true);

    connect(m_slider, SIGNAL(valueChanged(int)), m_valueSpinBox, SLOT(setValue(int)));
    connect(m_valueSpinBox, SIGNAL(valueChanged(int)), m_slider, SLOT(setValue(int)));
    connect(m_valueSpinBox, SIGNAL(valueChanged(int)), this, SLOT(setValue(int)));

    connect(m_slider, SIGNAL(valueChanged(int)), this, SIGNAL(valueChanged(int)));

    connect(m_selected, SIGNAL(toggled(bool)), parent, SLOT(selectionChanged(bool)));

    QBoxLayout *sliderLayout = new QBoxLayout(QBoxLayout::TopToBottom);
    sliderLayout->addWidget(m_slider);
    sliderLayout->addWidget(m_valueSpinBox);
    sliderLayout->addWidget(m_selected);

    setLayout(sliderLayout);
}

void BiquadSlider::setValue(int value)
{
    m_slider->setValue(value);
    m_valueSpinBox->setValue(value);
    valueChanged(m_index, value);
}

bool BiquadSlider::isChecked()
{
    return m_selected->isChecked();
}

void BiquadSlider::setSelected(bool selected)
{
    m_selected->setChecked(selected);
}
