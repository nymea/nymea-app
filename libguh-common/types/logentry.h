#ifndef LOGENTRY_H
#define LOGENTRY_H

#include <QObject>
#include <QVariant>
#include <QDateTime>

class LogEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value CONSTANT)
    Q_PROPERTY(QString deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QString typeId READ typeId CONSTANT)
    Q_PROPERTY(LoggingSource source READ source CONSTANT)
    Q_PROPERTY(LoggingEventType loggingEventType READ loggingEventType CONSTANT)

    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(QString timeString READ timeString CONSTANT)
    Q_PROPERTY(QString dayString READ dayString CONSTANT)
    Q_PROPERTY(QString dateString READ dateString CONSTANT)

public:
    enum LoggingSource {
        LoggingSourceSystem,
        LoggingSourceEvents,
        LoggingSourceActions,
        LoggingSourceStates,
        LoggingSourceRules
    };
    Q_ENUM(LoggingSource)
    Q_DECLARE_FLAGS(LoggingSources, LoggingSource)

    enum LoggingEventType {
        LoggingEventTypeTrigger,
        LoggingEventTypeActiveChange,
        LoggingEventTypeEnabledChange,
        LoggingEventTypeActionsExecuted,
        LoggingEventTypeExitActionsExecuted
    };
    Q_ENUM(LoggingEventType)

    explicit LogEntry(const QDateTime &timestamp, const QVariant &value, const QString &deviceId = QString(), const QString &typeId = QString(), LoggingSource source = LoggingSourceSystem, LoggingEventType loggingEventType = LoggingEventTypeTrigger, QObject *parent = nullptr);

    QVariant value() const;
    QDateTime timestamp() const;
    QString deviceId() const;
    QString typeId() const;
    LoggingSource source() const;
    LoggingEventType loggingEventType() const;

    QString timeString() const;
    QString dayString() const;
    QString dateString() const;

private:
    QVariant m_value;
    QDateTime m_timeStamp;
    QString m_deviceId;
    QString m_typeId;
    LoggingSource m_source;
    LoggingEventType m_loggingEventType;
};

#endif // LOGENTRY_H
