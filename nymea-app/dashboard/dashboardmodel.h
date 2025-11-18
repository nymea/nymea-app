// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DASHBOARDMODEL_H
#define DASHBOARDMODEL_H

#include <QAbstractListModel>

class DashboardItem;

class DashboardModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleType,
        RoleColumnSpan,
        RoleRowSpan,
    };
    Q_ENUM(Roles)

    explicit DashboardModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE DashboardItem* get(int index) const;

    Q_INVOKABLE void addThingItem(const QUuid &thingId, int index = -1);
    Q_INVOKABLE void addFolderItem(const QString &name, const QString &icon, int index = -1);
    Q_INVOKABLE void addGraphItem(const QUuid &thingId, const QUuid &stateTypeId, int index = -1);
    Q_INVOKABLE void addSceneItem(const QUuid &ruleId, int index = -1);
    Q_INVOKABLE void addWebViewItem(const QUrl &url, int columnSpan, int rowSpan, bool interactive, int index = -1);
    Q_INVOKABLE void addStateItem(const QUuid &thingId, const QUuid &stateTypeId, int index = -1);
    Q_INVOKABLE void addSensorItem(const QUuid &thingId, const QStringList &interfaces, int index = -1);

    Q_INVOKABLE void removeItem(int index);
    Q_INVOKABLE void move(int from, int to);

    Q_INVOKABLE void loadFromJson(const QByteArray &json);
    Q_INVOKABLE QByteArray toJson() const;
signals:
    void changed();
    void countChanged();

    void save();

private:
    void addItem(DashboardItem *item, int index = -1);

private:
    QList<DashboardItem*> m_list;

};


#endif // DASHBOARDMODEL_H
