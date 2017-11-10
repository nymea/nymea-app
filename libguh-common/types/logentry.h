#ifndef LOGENTRY_H
#define LOGENTRY_H

#include <QObject>
#include <QVariant>
#include <QDateTime>

class LogEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value CONSTANT)

    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(QString timeString READ timeString CONSTANT)
    Q_PROPERTY(QString dayString READ dayString CONSTANT)
    Q_PROPERTY(QString dateString READ dateString CONSTANT)

public:
    explicit LogEntry(const QDateTime &timestamp, const QVariant &value, QObject *parent = nullptr);

    QVariant value() const;
    QDateTime timestamp() const;

    QString timeString() const;
    QString dayString() const;
    QString dateString() const;

private:
    QVariant m_value;
    QDateTime m_timeStamp;
};

#endif // LOGENTRY_H
