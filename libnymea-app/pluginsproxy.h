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
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
public:
    explicit PluginsProxy(QObject *parent = nullptr);

    Plugins *plugins();
    void setPlugins(Plugins *plugins);

    bool showOnlyConfigurable() const;
    void setShowOnlyConfigurable(bool showOnlyConfigurable);

    QString filter() const;
    void setFilter(const QString &filter);

    Q_INVOKABLE Plugin* get(int index) const;
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

signals:
    void pluginsChanged();
    void showOnlyConfigurableChanged();
    void filterChanged();

private:
    Plugins *m_plugins = nullptr;
    bool m_showOnlyConfigurable = false;
    QString m_filter;
};

#endif // PLUGINSPROXY_H
