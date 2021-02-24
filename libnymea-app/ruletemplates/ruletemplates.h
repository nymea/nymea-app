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

#ifndef RULETEMPLATES_H
#define RULETEMPLATES_H

#include <QAbstractListModel>

class RuleTemplate;
class StateEvaluatorTemplate;
class TimeDescriptorTemplate;
class RepeatingOption;
class ThingsProxy;
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
    void setFilterByThings(ThingsProxy* filterThingsProxy) {if (m_filterThingsProxy !=  filterThingsProxy) { m_filterThingsProxy = filterThingsProxy; emit filterByThingsChanged(); invalidateFilter(); }}
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
