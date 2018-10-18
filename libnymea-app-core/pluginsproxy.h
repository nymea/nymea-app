/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
