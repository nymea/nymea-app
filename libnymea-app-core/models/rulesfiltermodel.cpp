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
    setSortRole(Rules::RoleName);
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
        emit countChanged();
        sort(0);
    }
}

QString RulesFilterModel::filterDeviceId() const
{
    return m_filterDeviceId;
}

void RulesFilterModel::setFilterDeviceId(const QString &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool RulesFilterModel::filterExecutable() const
{
    return m_filterExecutable;
}

void RulesFilterModel::setFilterExecutable(bool filterExecutable)
{
    if (m_filterExecutable != filterExecutable) {
        m_filterExecutable = filterExecutable;
        emit filterExecutableChanged();
        invalidateFilter();
        emit countChanged();
    }
}

Rule *RulesFilterModel::get(int index) const
{
    return m_rules->get(mapToSource(this->index(index, 0)).row());
}

bool RulesFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    Rule* rule = m_rules->get(source_row);
    if (m_filterExecutable && !rule->executable()) {
        return false;
    }
    bool found = true;
    if (!m_filterDeviceId.isNull()) {
        found = false;
        for (int i = 0; i < rule->eventDescriptors()->rowCount(); i++) {
            EventDescriptor *ed = rule->eventDescriptors()->get(i);
            if (ed->deviceId() == m_filterDeviceId) {
                found = true;
                break;
            }
        }
        if (!found && rule->stateEvaluator() && rule->stateEvaluator()->containsDevice(m_filterDeviceId)) {
            found = true;
        }
        if (!found) {
            for (int i = 0; i < rule->actions()->rowCount(); i++) {
                RuleAction *ra = rule->actions()->get(i);
                if (ra->deviceId() == m_filterDeviceId) {
                    found = true;
                    break;
                }
            }
        }
        if (!found) {
            for (int i = 0; i < rule->exitActions()->rowCount(); i++) {
                RuleAction *ra = rule->exitActions()->get(i);
                if (ra->deviceId() == m_filterDeviceId) {
                    found = true;
                    break;
                }
            }
        }
    }
    return found;
}
