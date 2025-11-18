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

#ifndef RULESFILTERMODEL_H
#define RULESFILTERMODEL_H

#include <QSortFilterProxyModel>
#include <QUuid>

class Rules;
class Rule;

class RulesFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Rules* rules READ rules WRITE setRules NOTIFY rulesChanged)
    Q_PROPERTY(QUuid filterThingId READ filterThingId WRITE setFilterThingId NOTIFY filterThingIdChanged)
    Q_PROPERTY(bool filterExecutable READ filterExecutable WRITE setFilterExecutable NOTIFY filterExecutableChanged)

public:
    explicit RulesFilterModel(QObject *parent = nullptr);

    Rules* rules() const;
    void setRules(Rules* rules);

    QUuid filterThingId() const;
    void setFilterThingId(const QUuid &filterThingId);

    bool filterExecutable() const;
    void setFilterExecutable(bool filterExecutable);

    Q_INVOKABLE Rule* get(int index) const;

signals:
    void rulesChanged();
    void filterThingIdChanged();
    void filterExecutableChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    Rules *m_rules = nullptr;
    QUuid m_filterThingId;
    bool m_filterExecutable = false;
};

#endif // RULESFILTERMODEL_H
