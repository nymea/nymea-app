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

#ifndef STATE_H
#define STATE_H

#include <QUuid>
#include <QObject>
#include <QVariant>

class State : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId CONSTANT)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId CONSTANT)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)

public:
    explicit State(const QUuid &deviceId, const QUuid &stateTypeId, const QVariant &value, QObject *parent = nullptr);

    QUuid deviceId() const;
    QUuid stateTypeId() const;

    QVariant value() const;
    void setValue(const QVariant &value);

private:
    QUuid m_deviceId;
    QUuid m_stateTypeId;
    QVariant m_value;

signals:
    void valueChanged();

};

#endif // STATE_H
