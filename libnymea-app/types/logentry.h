/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
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
