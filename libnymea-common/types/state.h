/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                       *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
    explicit State(const QUuid &deviceId, const QUuid &stateTypeId, const QVariant &value, QObject *parent = 0);

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
