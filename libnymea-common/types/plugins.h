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

#ifndef PLUGINS_H
#define PLUGINS_H

#include <QObject>
#include <QAbstractListModel>

#include "plugin.h"

class Plugins : public QAbstractListModel
{
    Q_OBJECT
public:
    enum StateRole {
        NameRole = Qt::DisplayRole,
        PluginIdRole
    };

    explicit Plugins(QObject *parent = 0);

    QList<Plugin *> plugins();

    Q_INVOKABLE int count() const;
    Q_INVOKABLE Plugin *get(int index) const;
    Q_INVOKABLE Plugin *getPlugin(const QUuid &pluginId) const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    void addPlugin(Plugin *plugin);

    void clearModel();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<Plugin *> m_plugins;

};

#endif // PLUGINS_H
