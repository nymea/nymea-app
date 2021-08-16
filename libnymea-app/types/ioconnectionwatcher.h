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

#ifndef IOCONNECTIONWATCHER_H
#define IOCONNECTIONWATCHER_H

#include <QObject>
#include <QUuid>

#include "ioconnection.h"
#include "ioconnections.h"

class IOInputConnectionWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(IOConnections* ioConnections READ ioConnections WRITE setIOConnections NOTIFY ioConnectionsChanged)
    Q_PROPERTY(QUuid inputThingId READ inputThingId WRITE setInputThingId NOTIFY inputThingIdChanged)
    Q_PROPERTY(QUuid inputStateTypeId READ inputStateTypeId WRITE setInputStateTypeId NOTIFY inputStateTypeIdChanged)
    Q_PROPERTY(IOConnection* ioConnection READ ioConnection NOTIFY ioConnectionChanged)
public:
    explicit IOInputConnectionWatcher(QObject *parent = nullptr);

    IOConnections* ioConnections() const;
    void setIOConnections(IOConnections *ioConnections);

    QUuid inputThingId() const;
    void setInputThingId(const QUuid &inputThingId);

    QUuid inputStateTypeId() const;
    void setInputStateTypeId(const QUuid &inputStateTypeId);

    IOConnection* ioConnection() const;

signals:
    void ioConnectionsChanged();
    void inputThingIdChanged();
    void inputStateTypeIdChanged();
    void ioConnectionChanged();

private:
    IOConnections *m_ioConnections = nullptr;
    QUuid m_inputThingId;
    QUuid m_inputStateTypeId;
};


class IOOutputConnectionWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(IOConnections* ioConnections READ ioConnections WRITE setIOConnections NOTIFY ioConnectionsChanged)
    Q_PROPERTY(QUuid outputThingId READ outputThingId WRITE setOutputThingId NOTIFY outputThingIdChanged)
    Q_PROPERTY(QUuid outputStateTypeId READ outputStateTypeId WRITE setOutputStateTypeId NOTIFY outputStateTypeIdChanged)
    Q_PROPERTY(IOConnection* ioConnection READ ioConnection NOTIFY ioConnectionChanged)
public:
    explicit IOOutputConnectionWatcher(QObject *parent = nullptr);

    IOConnections* ioConnections() const;
    void setIOConnections(IOConnections *ioConnections);

    QUuid outputThingId() const;
    void setOutputThingId(const QUuid &outputThingId);

    QUuid outputStateTypeId() const;
    void setOutputStateTypeId(const QUuid &outputStateTypeId);

    IOConnection* ioConnection() const;

signals:
    void ioConnectionsChanged();
    void outputThingIdChanged();
    void outputStateTypeIdChanged();
    void ioConnectionChanged();

private:
    IOConnections *m_ioConnections = nullptr;
    QUuid m_outputThingId;
    QUuid m_outputStateTypeId;
};

#endif // IOCONNECTIONWATCHER_H
