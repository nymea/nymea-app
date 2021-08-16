#ifndef BARSERIESADAPTER_H
#define BARSERIESADAPTER_H

#include "logsmodel.h"

#include <QObject>
#include <QBarSeries>
#include <QBarSet>

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
using namespace QtCharts;
#endif

class BarSeriesAdapter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(LogsModel* logsModel READ logsModel WRITE setLogsModel NOTIFY logsModelChanged)
    Q_PROPERTY(QAbstractBarSeries* barSeries READ barSeries WRITE setBarSeries NOTIFY barSeriesChanged)

    Q_PROPERTY(Interval interval READ interval WRITE setInterval NOTIFY intervalChanged)

public:
    enum Interval {
        IntervalMinutes = 60,
        IntervalHours =  60 * 60,
        IntervalDays = 24 * 60  * 60
    };
    Q_ENUM(Interval)

    explicit BarSeriesAdapter(QObject *parent = nullptr);

    LogsModel *logsModel() const;
    void setLogsModel(LogsModel *logsModel);

    QAbstractBarSeries *barSeries() const;
    void setBarSeries(QAbstractBarSeries *barSeries);

    Interval interval() const;
    void setInterval(Interval interval);

signals:
    void logsModelChanged();
    void barSeriesChanged();
    void intervalChanged();

private:
    void update();

    void ensureSlots(const QDateTime &start, const QDateTime &end);

private slots:
    void logEntryAdded(LogEntry *entry);

private:
    class TimeSlot {
    public:
        QDateTime datetime;
        QList<LogEntry*> entries;
        qreal value() const;
    };

    LogsModel *m_logsModel = nullptr;
    QAbstractBarSeries *m_barSeries = nullptr;
    QBarSet *m_set = nullptr;
    Interval m_interval = IntervalMinutes;

    QList<TimeSlot> m_timeslots;
};

#endif // BARSERIESADAPTER_H
