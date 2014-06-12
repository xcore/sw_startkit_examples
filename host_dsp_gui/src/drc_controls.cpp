#include <QtWidgets>

#include "drc_controls.h"
#include "drc_spinbox.h"
#include "qcustomplot.h"
#include "window.h"
#include "xscope_host_shared.h"

#define SLIDER_MIN 0
#define SLIDER_MAX 10000

#define ATTACK_INITIAL 1000
#define RELEASE_INITIAL 4000

DrcControls::DrcControls(const QString &title, QWidget *parent)
    : QGroupBox(title, parent)
{
    setDrcEntry(0, 60, 70);
    setDrcEntry(1, 70, 60);
    setDrcEntry(2, 80, 50);

    QBoxLayout *slidersLayout = new QBoxLayout(QBoxLayout::LeftToRight);

    // ATTACK
    m_attackMicroSec = new QSlider(Qt::Vertical);
    m_attackMicroSec->setFocusPolicy(Qt::StrongFocus);
    m_attackMicroSec->setTickPosition(QSlider::TicksBothSides);
    m_attackMicroSec->setTickInterval(SLIDER_MAX/10);
    m_attackMicroSec->setSingleStep(1);
    m_attackMicroSec->setMinimum(SLIDER_MIN);
    m_attackMicroSec->setMaximum(SLIDER_MAX);
    m_attackMicroSec->setValue(ATTACK_INITIAL);

    m_attackSpinBox = new QSpinBox;
    m_attackSpinBox->setRange(SLIDER_MIN, SLIDER_MAX);
    m_attackSpinBox->setSingleStep(1);
    m_attackSpinBox->setValue(ATTACK_INITIAL);

    QBoxLayout *attackLayout = new QBoxLayout(QBoxLayout::TopToBottom);
    attackLayout->addWidget(m_attackMicroSec);
    attackLayout->addWidget(m_attackSpinBox);
    QGroupBox *attackBox = new QGroupBox(tr("Attack Micro Sec"));
    attackBox->setLayout(attackLayout);

    connect(m_attackMicroSec, SIGNAL(valueChanged(int)), m_attackSpinBox, SLOT(setValue(int)));
    connect(m_attackSpinBox, SIGNAL(valueChanged(int)), m_attackMicroSec, SLOT(setValue(int)));

    // RELEASE
    m_releaseMicroSec = new QSlider(Qt::Vertical);
    m_releaseMicroSec->setFocusPolicy(Qt::StrongFocus);
    m_releaseMicroSec->setTickPosition(QSlider::TicksBothSides);
    m_releaseMicroSec->setTickInterval(SLIDER_MAX/10);
    m_releaseMicroSec->setSingleStep(1);
    m_releaseMicroSec->setMinimum(SLIDER_MIN);
    m_releaseMicroSec->setMaximum(SLIDER_MAX);
    m_releaseMicroSec->setValue(RELEASE_INITIAL);

    m_releaseSpinBox = new QSpinBox;
    m_releaseSpinBox->setRange(SLIDER_MIN, SLIDER_MAX);
    m_releaseSpinBox->setSingleStep(1);
    m_releaseSpinBox->setValue(RELEASE_INITIAL);

    QBoxLayout *releaseLayout = new QBoxLayout(QBoxLayout::TopToBottom);
    releaseLayout->addWidget(m_releaseMicroSec);
    releaseLayout->addWidget(m_releaseSpinBox);
    QGroupBox *releaseBox = new QGroupBox(tr("Release Micro Sec"));
    releaseBox->setLayout(releaseLayout);

    connect(m_releaseMicroSec, SIGNAL(valueChanged(int)), m_releaseSpinBox, SLOT(setValue(int)));
    connect(m_releaseSpinBox, SIGNAL(valueChanged(int)), m_releaseMicroSec, SLOT(setValue(int)));

    // THRESHOLD
    m_threshold = new QDial;
    m_threshold->setRange(0, 100);
    m_threshold->setSingleStep(1);
    m_threshold->setValue(20);

    m_thresholdSpinBox = new QSpinBox;
    m_thresholdSpinBox->setRange(0, 100);
    m_thresholdSpinBox->setSingleStep(1);
    m_thresholdSpinBox->setValue(20);

    QBoxLayout *thresholdLayout = new QBoxLayout(QBoxLayout::TopToBottom);
    thresholdLayout->addWidget(m_threshold);
    thresholdLayout->addWidget(m_thresholdSpinBox);
    QGroupBox *thresholdBox = new QGroupBox(tr("Level threshold"));
    thresholdBox->setLayout(thresholdLayout);

    connect(m_threshold, SIGNAL(valueChanged(int)), m_thresholdSpinBox, SLOT(setValue(int)));
    connect(m_thresholdSpinBox, SIGNAL(valueChanged(int)), m_threshold, SLOT(setValue(int)));

    // THRESHOLDS
    QGridLayout *thresholdsLayout = new QGridLayout();
    QGroupBox *thresholdsBox = new QGroupBox(tr("Thresholds"));

    QLabel *levelLabel = new QLabel(tr("Level"));
    QLabel *gainLabel = new QLabel(tr("Gain"));

    thresholdsLayout->addWidget(levelLabel, 0, 0);
    thresholdsLayout->addWidget(gainLabel, 0, 1);

    for (int i = 0; i < NUM_THRESHOLDS; i++)
    {
        DrcSpinBox *levelSpinBox = new DrcSpinBox(i, &m_drcTable[i].threshold);
        levelSpinBox->setRange(0, 100);
        levelSpinBox->setSingleStep(1);
        levelSpinBox->setValue(m_drcTable[i].threshold);

        DrcSpinBox *gainSpinBox = new DrcSpinBox(i, &m_drcTable[i].gain);
        gainSpinBox->setRange(0, 100);
        gainSpinBox->setSingleStep(1);
        gainSpinBox->setValue(m_drcTable[i].gain);

        thresholdsLayout->addWidget(levelSpinBox, i + 1, 0);
        thresholdsLayout->addWidget(gainSpinBox, i + 1, 1);

        connect(levelSpinBox, SIGNAL(valueChanged(int,int)), this, SLOT(levelThresholdUpdated(int,int)));
        connect(gainSpinBox, SIGNAL(valueChanged(int,int)), this, SLOT(levelThresholdUpdated(int,int)));
    }

    thresholdsBox->setLayout(thresholdsLayout);

    connect(m_threshold, SIGNAL(valueChanged(int)), m_thresholdSpinBox, SLOT(setValue(int)));
    connect(m_thresholdSpinBox, SIGNAL(valueChanged(int)), m_threshold, SLOT(setValue(int)));

    // DRC Plot
    m_drcGraph = new QCustomPlot();
    m_drcGraph->xAxis->setRange(0, 100);
    m_drcGraph->yAxis->setRange(0, 100);

    QBoxLayout *plotLayout = new QBoxLayout(QBoxLayout::TopToBottom);
    plotLayout->addWidget(m_drcGraph);
    QGroupBox *plotBox = new QGroupBox(tr("DRC"));
    plotBox->setLayout(plotLayout);

    // Connections to interact with target
    connect(m_attackMicroSec, SIGNAL(valueChanged(int)), parent, SLOT(setLevelAttack(int)));
    connect(m_releaseMicroSec, SIGNAL(valueChanged(int)), parent, SLOT(setLevelRelease(int)));
    connect(m_threshold, SIGNAL(valueChanged(int)), parent, SLOT(setLevelThreshold(int)));

    slidersLayout->addWidget(attackBox);
    slidersLayout->addWidget(releaseBox);
    slidersLayout->addWidget(thresholdBox);
    slidersLayout->addWidget(thresholdsBox);
    slidersLayout->addWidget(plotBox);
    setLayout(slidersLayout);

    m_drcGraph->addGraph();
    plotGraph();
}

void DrcControls::setDrcEntry(int index, int threshold, int gain)
{
    m_drcTable[index].threshold = threshold;
    m_drcTable[index].gain = gain;
}

void DrcControls::levelThresholdUpdated(int index, int value)
{
    char cmd[MAX_COMMAND_LEN] = "";
    memset(&cmd[0], 0, sizeof(cmd));
    sprintf(&cmd[0], "t %d %d %d", index, m_drcTable[index].threshold, m_drcTable[index].gain);
    xscope_ep_request_upload(g_sockfd, strlen(cmd) + 1, (const unsigned char *)cmd);

    plotGraph();
}

void DrcControls::plotGraph()
{
    int n = 5; // number of points in graph
    QVector<double> x(n), y(n);

    double currentX = 0.0;
    double currentY = 0.0;
    double currentGradient = 1.0;

    x[0] = currentX;
    y[0] = currentY;
    for (int i = 0; i < 3; i++)
    {
      x[i + 1] = double(m_drcTable[i].threshold);
      y[i + 1] = currentY + (double(m_drcTable[i].threshold) - currentX) * currentGradient;
      currentGradient = double(m_drcTable[i].gain) / 100.0;
      currentX = x[i+1];
      currentY = y[i+1];
    }

    x[4] = 100.0;
    y[4] = currentY + (100.0 - currentX) * currentGradient;

    m_drcGraph->graph(0)->setData(x, y);
    m_drcGraph->graph(0)->setLineStyle(QCPGraph::lsLine);
    m_drcGraph->replot();
}
