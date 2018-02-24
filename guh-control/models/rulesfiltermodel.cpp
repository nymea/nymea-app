#include "rulesfiltermodel.h"
#include "types/rules.h"
#include "types/rule.h"
#include "types/eventdescriptors.h"
#include "types/eventdescriptor.h"
#include "types/stateevaluator.h"
#include "types/ruleactions.h"
#include "types/ruleaction.h"

#include <QDebug>

RulesFilterModel::RulesFilterModel(QObject *parent) : QSortFilterProxyModel(parent)
{

}

Rules *RulesFilterModel::rules() const
{
    return m_rules;
}

void RulesFilterModel::setRules(Rules *rules)
{
    if (m_rules != rules) {
        m_rules = rules;
        setSourceModel(rules);
        emit rulesChanged();
        invalidateFilter();
    }
}

QUuid RulesFilterModel::filterDeviceId() const
{
    return m_filterDeviceId;
}

void RulesFilterModel::setFilterDeviceId(const QUuid &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
    }
}

Rule *RulesFilterModel::get(int index) const
{
    return m_rules->get(mapToSource(this->index(index, 0)).row());
}

bool RulesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    bool found = true;
    if (!m_filterDeviceId.isNull()) {
        Rule* rule = m_rules->get(source_row);
        found = false;
        for (int i = 0; i < rule->eventDescriptors()->rowCount(); i++) {
            EventDescriptor *ed = rule->eventDescriptors()->get(i);
            if (ed->deviceId() == m_filterDeviceId) {
                found = true;
                break;
            }
        }
        if (!found && rule->stateEvaluator()->containsDevice(m_filterDeviceId)) {
            found = true;
        }
        if (!found) {
            for (int i = 0; i < rule->ruleActions()->rowCount(); i++) {
                RuleAction *ra = rule->ruleActions()->get(i);
                if (ra->deviceId() == m_filterDeviceId) {
                    found = true;
                    break;
                }
            }
        }
    }
    return found;
}
