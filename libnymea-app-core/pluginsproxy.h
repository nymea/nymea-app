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

#ifndef PLUGINSPROXY_H
#define PLUGINSPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "types/plugins.h"

class PluginsProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Plugins* plugins READ plugins WRITE setPlugins NOTIFY pluginsChanged)
    Q_PROPERTY(bool showOnlyConfigurable READ showOnlyConfigurable WRITE setShowOnlyConfigurable NOTIFY showOnlyConfigurableChanged)
public:
    explicit PluginsProxy(QObject *parent = nullptr);

    Plugins *plugins();
    void setPlugins(Plugins *plugins);

    bool showOnlyConfigurable() const;
    void setShowOnlyConfigurable(bool showOnlyConfigurable);

    Q_INVOKABLE Plugin* get(int index) const;
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void pluginsChanged();
    void showOnlyConfigurableChanged();

private:
    Plugins *m_plugins = nullptr;
    bool m_showOnlyConfigurable = false;
};

#endif // PLUGINSPROXY_H
