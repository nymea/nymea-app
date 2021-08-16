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

#ifndef RULEACTION_H
#define RULEACTION_H

#include <QObject>
#include <QUuid>

#include "ruleactionparams.h"

class RuleAction : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QUuid actionTypeId READ actionTypeId WRITE setActionTypeId NOTIFY actionTypeIdChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceAction READ interfaceAction WRITE setInterfaceAction NOTIFY interfaceActionChanged)
    Q_PROPERTY(QString browserItemId READ browserItemId WRITE setBrowserItemId NOTIFY browserItemIdChanged)
    Q_PROPERTY(RuleActionParams* ruleActionParams READ ruleActionParams CONSTANT)

public:
    explicit RuleAction(QObject *parent = nullptr);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QUuid actionTypeId() const;
    void setActionTypeId(const QUuid &actionTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceAction() const;
    void setInterfaceAction(const QString &interfaceAction);

    QString browserItemId() const;
    void setBrowserItemId(const QString &browserItemId);

    RuleActionParams* ruleActionParams() const;

    RuleAction *clone() const;
    bool operator==(RuleAction *other) const;

signals:
    void thingIdChanged();
    void actionTypeIdChanged();
    void interfaceNameChanged();
    void interfaceActionChanged();
    bool browserItemIdChanged();

private:
    QUuid m_thingId;
    QUuid m_actionTypeId;
    QString m_interfaceName;
    QString m_interfaceAction;
    QString m_browserItemId;
    RuleActionParams *m_ruleActionParams;
};

#endif // RULEACTION_H
