#ifndef _DRC_SPINBOX_H_
#define _DRC_SPINBOX_H_

#include <QSpinBox>

class DrcSpinBox : public QSpinBox
{
    Q_OBJECT

public:
    /* The DRC spin box takes the index into the DRC table and a
     * pointer to the integer value that it is controlling.
     */
    DrcSpinBox(int index, int *valuePtr);

signals:
    /* The signal that provides the table index */
    void valueChanged(int index, int value);

public slots:
    void valueSet(int value);

private:
    int  m_index;
    int *m_valuePtr;
};

#endif // _DRC_SPINBOX_H_
