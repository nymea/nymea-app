#ifndef VALUELOGSPROXYMODEL_H
#define VALUELOGSPROXYMODEL_H

#include <QAbstractListModel>

#include "logsmodel.h"

class ValueLogsProxyModel : public LogsModel
{
    Q_OBJECT
    Q_PROPERTY(Average average READ average WRITE setAverage NOTIFY averageChanged)

    Q_PROPERTY(QVariant minimumValue READ minimumValue NOTIFY minimumValueChanged)
    Q_PROPERTY(QVariant maximumValue READ maximumValue NOTIFY maximumValueChanged)

public:
    enum Average {
        AverageMonth,
        AverageDay,
        AverageDayTime,
        AverageHourly,
        AverageQuarterHour,
        AverageMinute
    };
    Q_ENUM(Average)

    explicit ValueLogsProxyModel(QObject *parent = nullptr);

    void update() override;

    Average average() const;
    void setAverage(Average average);

    QVariant minimumValue() const;
    QVariant maximumValue() const;

signals:
    void averageChanged();

    void minimumValueChanged();
    void maximumValueChanged();

protected:
    void logsReply(const QVariantMap &data) override;

private:
    Average m_average = AverageHourly;

    QVariant m_minimumValue;
    QVariant m_maximumValue;
};

#endif // VALUELOGSPROXYMODEL_H
