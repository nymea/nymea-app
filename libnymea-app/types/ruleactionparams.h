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

#ifndef RULEACTIONPARAMS_H
#define RULEACTIONPARAMS_H

#include <QAbstractListModel>

class RuleActionParam;

class RuleActionParams : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleParamTypeId,
        RoleValue,
        RoleEventTypeId,
        RoleEventParamTypeId
    };
    Q_ENUM(Roles)

    explicit RuleActionParams(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addRuleActionParam(RuleActionParam* ruleActionParam);

    Q_INVOKABLE void setRuleActionParam(const QUuid &paramTypeId, const QVariant &value);
    Q_INVOKABLE void setRuleActionParamByName(const QString &paramName, const QVariant &value);
    Q_INVOKABLE void setRuleActionParamEvent(const QString &paramTypeId, const QString &eventTypeId, const QString &eventParamTypeId);
    Q_INVOKABLE void setRuleActionParamEventByName(const QString &paramName, const QString &eventTypeId, const QString &eventParamTypeId);
    Q_INVOKABLE void setRuleActionParamState(const QString &paramTypeId, const QString &stateThingId, const QString &stateTypeId);
    Q_INVOKABLE void setRuleActionParamStateByName(const QString &paramName, const QString &stateThingId, const QString &stateTypeId);

    Q_INVOKABLE RuleActionParam* get(int index) const;
    Q_INVOKABLE RuleActionParam* getParam(const QUuid &paramTypeId);

    Q_INVOKABLE bool hasRuleActionParam(const QString &paramTypeId) const;

    Q_INVOKABLE void clear();

    bool operator==(RuleActionParams *other) const;

signals:
    void countChanged();

private:
    QList<RuleActionParam*> m_list;
};

#endif // RULEACTIONPARAMS_H
