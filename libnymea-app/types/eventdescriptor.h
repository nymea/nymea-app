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

#ifndef EVENTDESCRIPTOR_H
#define EVENTDESCRIPTOR_H

#include <QObject>
#include <QUuid>

#include "paramdescriptors.h"

class EventDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QUuid eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)

    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceEvent READ interfaceEvent WRITE setInterfaceEvent NOTIFY interfaceEventChanged)

    Q_PROPERTY(ParamDescriptors* paramDescriptors READ paramDescriptors CONSTANT)

public:
    explicit EventDescriptor(QObject *parent = nullptr);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QUuid eventTypeId() const;
    void setEventTypeId(const QUuid &eventTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceEvent() const;
    void setInterfaceEvent(const QString &interfaceEvent);

    ParamDescriptors* paramDescriptors() const;

    EventDescriptor* clone() const;
    bool operator==(EventDescriptor* other) const;

signals:
    void thingIdChanged();
    void eventTypeIdChanged();
    void interfaceNameChanged();
    void interfaceEventChanged();

private:
    QUuid m_thingId;
    QUuid m_eventTypeId;

    QString m_interfaceName;
    QString m_interfaceEvent;

    ParamDescriptors *m_paramDescriptors;
};

#endif // EVENTDESCRIPTOR_H
