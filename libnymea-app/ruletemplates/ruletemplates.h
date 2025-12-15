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

#ifndef RULETEMPLATES_H
#define RULETEMPLATES_H

#include <QAbstractListModel>
#include "thingsproxy.h"

class RuleTemplate;
class StateEvaluatorTemplate;
class TimeDescriptorTemplate;
class RepeatingOption;
class Thing;

class RuleTemplates : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleDescription,
        RoleInterfaces
    };
    Q_ENUM(Roles)

    explicit RuleTemplates(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE RuleTemplate* get(int index) const;

signals:
    void countChanged();

private:
    StateEvaluatorTemplate* loadStateEvaluatorTemplate(const QVariantMap &stateEvaluatorTemplate) const;
    TimeDescriptorTemplate* loadTimeDescriptorTemplate(const QVariantMap &timeDescriptorTemplate) const;
    RepeatingOption* loadRepeatingOption(const QVariantMap &repeatingOptionMap) const;

private:
    QList<RuleTemplate*> m_list;

};

#include <QSortFilterProxyModel>

class RuleTemplatesFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(RuleTemplates* ruleTemplates READ ruleTemplates WRITE setRuleTemplates NOTIFY ruleTemplatesChanged)
    Q_PROPERTY(QStringList filterInterfaceNames READ filterInterfaceNames WRITE setFilterInterfaceNames NOTIFY filterInterfaceNamesChanged)
    Q_PROPERTY(ThingsProxy* filterByThings READ filterByThings WRITE setFilterByThings NOTIFY filterByThingsChanged)

public:
    RuleTemplatesFilterModel(QObject *parent = nullptr): QSortFilterProxyModel(parent) {}
    RuleTemplates* ruleTemplates() const { return m_ruleTemplates; }
    void setRuleTemplates(RuleTemplates* ruleTemplates) { if (m_ruleTemplates != ruleTemplates) { m_ruleTemplates = ruleTemplates; setSourceModel(ruleTemplates); emit ruleTemplatesChanged(); invalidateFilter(); emit countChanged();}}
    QStringList filterInterfaceNames() const { return m_filterInterfaceNames; }
    void setFilterInterfaceNames(const QStringList &filterInterfaceNames) { if (m_filterInterfaceNames != filterInterfaceNames) { m_filterInterfaceNames = filterInterfaceNames; emit filterInterfaceNamesChanged(); invalidateFilter(); emit countChanged(); }}
    ThingsProxy* filterByThings() const { return m_filterThingsProxy; }
    void setFilterByThings(ThingsProxy* filterThingsProxy);
    Q_INVOKABLE RuleTemplate* get(int index) {
        if (index < 0 || index >= rowCount()) {
            return nullptr;
        }
        return m_ruleTemplates->get(mapToSource(this->index(index, 0)).row());
    }
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool stateEvaluatorTemplateContainsInterface(StateEvaluatorTemplate *stateEvaluatorTemplate, const QStringList &interfaceNames) const;
signals:
    void ruleTemplatesChanged();
    void filterInterfaceNamesChanged();
    void filterByThingsChanged();
    void countChanged();


private:
    bool thingsSatisfyRuleTemplate(RuleTemplate *ruleTemplate, ThingsProxy *things) const;
    bool thingsSatisfyStateEvaluatorTemplate(StateEvaluatorTemplate *stateEvaluatorTemplate, ThingsProxy *things) const;

private:
    RuleTemplates* m_ruleTemplates = nullptr;
    QStringList m_filterInterfaceNames;
    ThingsProxy* m_filterThingsProxy = nullptr;
};

#endif // RULETEMPLATES_H
