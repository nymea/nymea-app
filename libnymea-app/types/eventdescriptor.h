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
