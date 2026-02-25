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
