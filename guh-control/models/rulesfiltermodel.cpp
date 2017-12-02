#include "rulesfiltermodel.h"
#include "types/rules.h"
#include "types/rule.h"
#include "types/eventdescriptors.h"
#include "types/eventdescriptor.h"
#include "types/stateevaluator.h"

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

QUuid RulesFilterModel::filterEventDeviceId() const
{
    return m_filterEventDeviceId;
}

void RulesFilterModel::setFilterEventDeviceId(const QUuid &filterEventDeviceId)
{
    if (m_filterEventDeviceId != filterEventDeviceId) {
        m_filterEventDeviceId = filterEventDeviceId;
        emit filterEventDeviceIdChanged();
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
    if (!m_filterEventDeviceId.isNull()) {
        Rule* rule = m_rules->get(source_row);
        bool found = false;
        for (int i = 0; i < rule->eventDescriptors()->rowCount(); i++) {
            EventDescriptor *ed = rule->eventDescriptors()->get(i);
            if (ed->deviceId() == m_filterEventDeviceId) {
                found = true;
                break;
            }
        }
        if (!found && !rule->stateEvaluator()->containsDevice(m_filterEventDeviceId)) {
            return false;
        }
    }
    return true;
}
