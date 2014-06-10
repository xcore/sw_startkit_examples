#ifndef _DRC_CONTROLS_H_
#define _DRC_CONTROLS_H_

#include <QGroupBox>

QT_BEGIN_NAMESPACE
class QSlider;
class QSpinBox;
class QDial;
class QCustomPlot;
QT_END_NAMESPACE

#define NUM_THRESHOLDS 3

typedef struct {
    int threshold;
    int gain;
} DrcTableEntry;

class DrcControls : public QGroupBox
{
    Q_OBJECT

public:
    DrcControls(const QString &title, QWidget *parent = 0);

public slots:
    void levelThresholdUpdated(int index, int value);

private:
    void plotGraph();
    void setDrcEntry(int index, int threshold, int gain);

private:
    QSlider *m_attackMicroSec;
    QSpinBox *m_attackSpinBox;

    QSlider *m_releaseMicroSec;
    QSpinBox *m_releaseSpinBox;

    QDial *m_threshold;
    QSpinBox *m_thresholdSpinBox;

    QCustomPlot *m_drcGraph;

    DrcTableEntry m_drcTable[NUM_THRESHOLDS];
};

#endif // _DRC_CONTROLS_H_
