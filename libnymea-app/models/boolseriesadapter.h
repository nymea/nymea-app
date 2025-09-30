#ifndef BOOLSERIESADAPTER_H
#define BOOLSERIESADAPTER_H

#include "logsmodel.h"

#include <QObject>
#include <QXYSeries>

class BoolSeriesAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LogsModel* logsModel READ logsModel WRITE setLogsModel NOTIFY logsModelChanged)
    Q_PROPERTY(QXYSeries* xySeries READ xySeries WRITE setXySeries NOTIFY xySeriesChanged)

    Q_PROPERTY(bool inverted READ inverted WRITE setInverted NOTIFY invertedChanged)

public:
    explicit BoolSeriesAdapter(QObject *parent = nullptr);

    LogsModel* logsModel() const;
    void setLogsModel(LogsModel *logsModel);

    QXYSeries* xySeries() const;
    void setXySeries(QXYSeries *series);

    bool inverted() const;
    void setInverted(bool inverted);

signals:
    void xySeriesChanged();
    void logsModelChanged();
    void invertedChanged();

private slots:
    void logEntryAdded(LogEntry *entry);

private:
    qreal calculateSampleValue(int index);

    quint64 findIndex(qulonglong timestamp);

private:
    LogsModel* m_model = nullptr;
    QXYSeries* m_series = nullptr;
    bool m_inverted = false;

};

#endif // BOOLSERIESADAPTER_H
