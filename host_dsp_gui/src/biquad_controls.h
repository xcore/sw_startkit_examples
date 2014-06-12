#ifndef _BIQUAD_CONTROLS_H_
#define _BIQUAD_CONTROLS_H_

#include <QGroupBox>

QT_BEGIN_NAMESPACE
class BiquadSlider;
QT_END_NAMESPACE

#define NUM_BIQUADS 10

class BiquadControls : public QGroupBox
{
    Q_OBJECT

public:
    BiquadControls(const QString &title, QWidget *parent = 0);

    bool allSelected();

public slots:
    void selectAll();
    void selectNone();
    void invertSelection();
    void selectionChanged(bool selected);

private:
    BiquadSlider *m_controls[NUM_BIQUADS];
};

#endif // _BIQUAD_CONTROLS_H_
