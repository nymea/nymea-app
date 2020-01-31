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
    Q_PROPERTY(QString stateDeviceId READ stateDeviceId WRITE setStateDeviceId NOTIFY stateDeviceIdChanged)
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

    QString stateDeviceId() const;
    void setStateDeviceId(const QString &stateDeviceId);

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
    void stateDeviceIdChanged();
    void stateTypeIdChanged();

    void isValueBasedChanged();
    void isEventParamBasedChanged();
    void isStateValueBasedChanged();

protected:
    QString m_paramName;
    QString m_eventTypeId;
    QString m_eventParamTypeId;
    QString m_stateDeviceId;
    QString m_stateTypeId;
};

#endif // RULEACTIONPARAM_H
