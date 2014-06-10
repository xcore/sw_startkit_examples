#include <QtWidgets>

#include "drc_spinbox.h"

DrcSpinBox::DrcSpinBox(int index, int *valuePtr)
    : m_index(index)
    , m_valuePtr(valuePtr)
{
    connect(this, SIGNAL(valueChanged(int)), this, SLOT(valueSet(int)));
}

void DrcSpinBox::valueSet(int value)
{
    *m_valuePtr = value;
    valueChanged(m_index, value);
}
