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

#ifndef IOCONNECTION_H
#define IOCONNECTION_H

#include <QObject>
#include <QUuid>

class IOConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid id READ id CONSTANT)
    Q_PROPERTY(QUuid inputThingId READ inputThingId CONSTANT)
    Q_PROPERTY(QUuid inputStateTypeId READ inputStateTypeId CONSTANT)
    Q_PROPERTY(QUuid outputThingId READ outputThingId CONSTANT)
    Q_PROPERTY(QUuid outputStateTypeId READ outputStateTypeId CONSTANT)
    Q_PROPERTY(bool inverted READ inverted CONSTANT)

public:
    explicit IOConnection(const QUuid &id, const QUuid &inputThingId, const QUuid &inputStateTypeId, const QUuid &outputThingId, const QUuid &outputStateTypeId, bool inverted, QObject *parent = nullptr);

    QUuid id() const;
    QUuid inputThingId() const;
    QUuid inputStateTypeId() const;
    QUuid outputThingId() const;
    QUuid outputStateTypeId() const;
    bool inverted() const;

private:
    QUuid m_id;
    QUuid m_inputThingId;
    QUuid m_inputStateTypeId;
    QUuid m_outputThingId;
    QUuid m_outputStateTypeId;
    bool m_inverted = false;
};

#endif // IOCONNECTION_H
