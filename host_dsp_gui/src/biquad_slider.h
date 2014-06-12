#ifndef _BIQUAD_SLIDER_H_
#define _BIQUAD_SLIDER_H_

#include <QGroupBox>

QT_BEGIN_NAMESPACE
class QSlider;
class QSpinBox;
class QCheckBox;
QT_END_NAMESPACE

class BiquadSlider : public QGroupBox
{
    Q_OBJECT

public:
    BiquadSlider(const QString &title, int index, QWidget *parent = 0);

    virtual bool isChecked();

signals:
    void valueChanged(int value);
    void valueChanged(int index, int value);

public slots:
    void setValue(int value);
    void setSelected(bool selected);

private:
    int m_index;
    QSlider *m_slider;
    QSpinBox *m_valueSpinBox;
    QCheckBox *m_selected;
};

#endif // _BIQUAD_SLIDER_H_
