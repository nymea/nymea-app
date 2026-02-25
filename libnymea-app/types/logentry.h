// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef LOGENTRY_H
#define LOGENTRY_H

#include <QObject>
#include <QVariant>
#include <QDateTime>
#include <QUuid>

class LogEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value CONSTANT)
    Q_PROPERTY(QUuid thingId READ thingId CONSTANT)
    Q_PROPERTY(QUuid typeId READ typeId CONSTANT)
    Q_PROPERTY(LoggingSource source READ source CONSTANT)
    Q_PROPERTY(LoggingEventType loggingEventType READ loggingEventType CONSTANT)

    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(QString timeString READ timeString CONSTANT)
    Q_PROPERTY(QString dayString READ dayString CONSTANT)
    Q_PROPERTY(QString dateString READ dateString CONSTANT)
    Q_PROPERTY(QString errorCode READ errorCode CONSTANT)

public:
    enum LoggingSource {
        LoggingSourceSystem = 0x01,
        LoggingSourceEvents = 0x02,
        LoggingSourceActions = 0x04,
        LoggingSourceStates = 0x08,
        LoggingSourceRules = 0x10
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

    explicit LogEntry(const QDateTime &timestamp, const QVariant &value, const QUuid &thingId = QUuid(), const QUuid &typeId = QUuid(), LoggingSource source = LoggingSourceSystem, LoggingEventType loggingEventType = LoggingEventTypeTrigger, const QString &errorCode = QString(), QObject *parent = nullptr);

    QVariant value() const;
    QDateTime timestamp() const;
    QUuid thingId() const;
    QUuid typeId() const;
    LoggingSource source() const;
    LoggingEventType loggingEventType() const;

    QString timeString() const;
    QString dayString() const;
    QString dateString() const;
    QString errorCode() const;

private:
    QVariant m_value;
    QDateTime m_timeStamp;
    QUuid m_thingId;
    QUuid m_typeId;
    LoggingSource m_source;
    LoggingEventType m_loggingEventType;
    QString m_errorCode;
};

#endif // LOGENTRY_H
