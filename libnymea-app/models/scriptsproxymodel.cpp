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
