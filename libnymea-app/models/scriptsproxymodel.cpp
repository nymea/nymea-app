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

#include "scriptsproxymodel.h"

#include "types/script.h"

ScriptsProxyModel::ScriptsProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{

}

Scripts *ScriptsProxyModel::scripts() const
{
    return m_scripts;
}

void ScriptsProxyModel::setScripts(Scripts *scripts)
{
    if (m_scripts != scripts) {
        if (m_scripts) {
            disconnect(m_scripts, &Scripts::countChanged, this, &ScriptsProxyModel::countChanged);
        }
        m_scripts = scripts;
        setSourceModel(scripts);
        emit scriptsChanged();

        if (m_scripts) {
            connect(m_scripts, &Scripts::countChanged, this, &ScriptsProxyModel::countChanged);
        }

        emit countChanged();
    }
}

QString ScriptsProxyModel::filterName() const
{
    return m_filterName;
}

void ScriptsProxyModel::setFilterName(const QString &filterName)
{
    if (m_filterName != filterName) {
        m_filterName = filterName;
        emit filterNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

Script *ScriptsProxyModel::get(int index) const
{
    return m_scripts->get(mapToSource(this->index(index, 0)).row());
}

bool ScriptsProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    Script *script = m_scripts->get(sourceRow);
    if (!m_filterName.isEmpty()) {
        if (!script->name().contains(m_filterName)) {
            return false;
        }
    }
    return true;
}
