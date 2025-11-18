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

#ifndef RULEACTIONPARAM_H
#define RULEACTIONPARAM_H

#include <QObject>
#include <QUuid>
#include <QVariant>

#include "param.h"

class RuleActionParam : public Param
{
    Q_OBJECT
    Q_PROPERTY(QString paramName READ paramName WRITE setParamName NOTIFY paramNameChanged)
    Q_PROPERTY(QString eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)
    Q_PROPERTY(QString eventParamTypeId READ eventParamTypeId WRITE setEventParamTypeId NOTIFY eventParamTypeIdChanged)
    Q_PROPERTY(QString stateThingId READ stateThingId WRITE setStateThingId NOTIFY stateThingIdChanged)
    Q_PROPERTY(QString stateTypeId READ stateTypeId WRITE setStateTypeId NOTIFY stateTypeIdChanged)

    Q_PROPERTY(bool isValueBased READ isValueBased NOTIFY isValueBasedChanged)
    Q_PROPERTY(bool isEventParamBased READ isEventParamBased NOTIFY isEventParamBasedChanged)
    Q_PROPERTY(bool isStateValueBased READ isStateValueBased NOTIFY isStateValueBasedChanged)

public:
    explicit RuleActionParam(const QString &paramName, const QVariant &value, QObject *parent = nullptr);
    explicit RuleActionParam(QObject *parent = nullptr);

    QString paramName() const;
    void setParamName(const QString &paramName);

    QString eventTypeId() const;
    void setEventTypeId(const QString &eventTypeId);

    QString eventParamTypeId() const;
    void setEventParamTypeId(const QString &eventParamTypeId);

    QString stateThingId() const;
    void setStateThingId(const QString &stateThingId);

    QString stateTypeId() const;
    void setStateTypeId(const QString &stateTypeId);

    bool isValueBased() const;
    bool isEventParamBased() const;
    bool isStateValueBased() const;

    RuleActionParam* clone() const;
    bool operator==(RuleActionParam *other) const;
signals:
    void paramNameChanged();
    void eventTypeIdChanged();
    void eventParamTypeIdChanged();
    void stateThingIdChanged();
    void stateTypeIdChanged();

    void isValueBasedChanged();
    void isEventParamBasedChanged();
    void isStateValueBasedChanged();

protected:
    QString m_paramName;
    QString m_eventTypeId;
    QString m_eventParamTypeId;
    QString m_stateThingId;
    QString m_stateTypeId;
};

#endif // RULEACTIONPARAM_H
