#include "valuelogsproxymodel.h"

#include <QDebug>

ValueLogsProxyModel::ValueLogsProxyModel(QObject *parent) : LogsModel(parent)
{
    m_minimumValue = QVariant(0);
    m_maximumValue = QVariant(0);
}

void ValueLogsProxyModel::update()
{
    // modify starttime to add a day earlier so we have more chances to have meaningful data right from the start
    m_startTime = m_startTime.addDays(-1);
    LogsModel::update();
    m_startTime = m_startTime.addDays(1);
}

ValueLogsProxyModel::Average ValueLogsProxyModel::average() const
{
    return m_average;
}

void ValueLogsProxyModel::setAverage(ValueLogsProxyModel::Average average)
{
    if (m_average != average) {
        m_average = average;
        emit averageChanged();
    }
}

QVariant ValueLogsProxyModel::minimumValue() const
{
    return m_minimumValue;
}

QVariant ValueLogsProxyModel::maximumValue() const
{
    return m_maximumValue;
}

void ValueLogsProxyModel::logsReply(const QVariantMap &data)
{

    qDebug() << "logs reply";

    beginResetModel();

    m_minimumValue = QVariant();
    m_maximumValue = QVariant();

    int stepSize = 1;
    switch (m_average) {
    case AverageMonth:
        stepSize *= 30;
    case AverageDay:
        stepSize *= 8;
    case AverageDayTime:
        stepSize *= 3;
    case AverageHourly:
        stepSize *= 4;
    case AverageQuarterHour:
        stepSize *= 15;
    case AverageMinute:
        stepSize *= 60;
    }
    int totalSlots = startTime().secsTo(endTime()) / stepSize;
    qDebug() << "slots" << totalSlots;

    QHash<int, QList<QVariant> > entries;

    QList<QVariant> logEntries = data.value("params").toMap().value("logEntries").toList();

    QVariant startValue;
    for (int i = 0; i < logEntries.count(); i++) {
        QVariantMap entryMap = logEntries.at(i).toMap();
        QDateTime entryTimestamp = QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
        int slot = startTime().secsTo(entryTimestamp) / stepSize;
        if (slot < 0) {
            // We're before the actual starttime (see update()). store the most recent value
            startValue = entryMap.value("value");
//            qDebug() << "have new startvalue" << startValue << entryTimestamp;
            continue;
        }
        QList<QVariant> tmp = entries[slot];
        QVariant value = entryMap.value("value");
        value.convert(QVariant::Double);
        tmp.append(value);
        entries[slot] = tmp;
//        qDebug() << "adding value to slot" << slot << entryMap.value("value") << QDateTime::fromMSecsSinceEpoch(entryMap.value("timestamp").toLongLong());
    }
    if (!startValue.isNull() && entries[0].isEmpty()) {
        QList<QVariant> tmp;
        tmp.append(startValue);
        entries[0] = tmp;
    }
//    qDebug() << "slotsize:" << stepSize << entries.keys();

    qDeleteAll(m_list);
    m_list.clear();
    for (int i = 0; i <= totalSlots; i++) {
        QVariant avg = 0;
        int counter = 0;
        foreach (const QVariant &value, entries[i]) {
            avg = avg.toDouble() + value.toDouble();
            counter++;
        }
        if (counter > 0) {
            avg = avg.toDouble() / counter;
        } else if (entries[i-1].count() > 0) {
            avg = entries[i-1].last();
        } else if (m_list.count() > 0){
            avg = m_list.last()->value();
        } else {
            continue;
        }
        LogEntry *entry = new LogEntry(startTime().addSecs(stepSize * i).addSecs(stepSize * .5), avg, this);
        m_list.append(entry);

//        qDebug() << "**" << m_minimumValue << entry->value();
        if (m_minimumValue.isNull() || entry->value() < m_minimumValue) {
            m_minimumValue = qRound(entry->value().toDouble());
        }
        if (m_maximumValue.isNull() || entry->value() > m_maximumValue) {
            m_maximumValue = qRound(entry->value().toDouble());
        }
        qDebug() << "filling slot" << i << "average:" << avg << entry->timestamp().toString() << "min:" << m_minimumValue << "max:" << m_maximumValue;

    }

    endResetModel();

    emit minimumValueChanged();
    emit maximumValueChanged();
    emit countChanged();
    qDebug() << "min" << minimumValue() << "max" << maximumValue();

    m_busy = false;
    emit busyChanged();

}
