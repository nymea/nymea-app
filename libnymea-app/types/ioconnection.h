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
