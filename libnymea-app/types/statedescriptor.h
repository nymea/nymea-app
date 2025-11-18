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

#ifndef STATEDESCRIPTOR_H
#define STATEDESCRIPTOR_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class StateDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId WRITE setStateTypeId NOTIFY stateTypeIdChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceState READ interfaceState WRITE setInterfaceState NOTIFY interfaceStateChanged)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator WRITE setValueOperator NOTIFY valueOperatorChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QUuid valueThingId READ valueThingId WRITE setValueThingId NOTIFY valueThingIdChanged)
    Q_PROPERTY(QUuid valueStateTypeId READ valueStateTypeId WRITE setValueStateTypeId NOTIFY valueStateTypeIdChanged)

public:
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    explicit StateDescriptor(const QUuid &thingId, const QUuid &stateTypeId, ValueOperator valueOperator, const QVariant &value, QObject *parent = nullptr);
    explicit StateDescriptor(const QString &interfaceName, const QString &interfaceState, ValueOperator valueOperator, const QVariant &value, QObject *parent = nullptr);
    StateDescriptor(QObject *parent = nullptr);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QUuid stateTypeId() const;
    void setStateTypeId(const QUuid &stateTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceState() const;
    void setInterfaceState(const QString &interfaceState);

    ValueOperator valueOperator() const;
    void setValueOperator(ValueOperator valueOperator);

    QVariant value() const;
    void setValue(const QVariant &value);

    QUuid valueThingId() const;
    void setValueThingId(const QUuid &valueThingId);

    QUuid valueStateTypeId() const;
    void setValueStateTypeId(const QUuid &valueStateTypeId);

    StateDescriptor* clone() const;
    bool operator==(StateDescriptor *other) const;

signals:
    void thingIdChanged();
    void stateTypeIdChanged();
    void interfaceNameChanged();
    void interfaceStateChanged();
    void valueOperatorChanged();
    void valueChanged();
    void valueThingIdChanged();
    void valueStateTypeIdChanged();

private:
    QUuid m_thingId;
    QUuid m_stateTypeId;
    QString m_interfaceName;
    QString m_interfaceState;
    ValueOperator m_operator = ValueOperatorEquals;
    QVariant m_value;
    QUuid m_valueThingId;
    QUuid m_valueStateTypeId;
};

#endif // STATEDESCRIPTOR_H
