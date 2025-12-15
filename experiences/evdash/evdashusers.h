// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef EVDASHUSERS_H
#define EVDASHUSERS_H

#include <QHash>
#include <QStringList>
#include <QAbstractListModel>

class EvDashUsers : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles { DisplayRole = Qt::UserRole + 1, NameRole };

    explicit EvDashUsers(QObject *parent = nullptr);
    explicit EvDashUsers(const QStringList &data, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setUsers(const QStringList &users);
    void addUser(const QString &username);
    void removeUser(const QString &username);

private:
    QStringList m_data;

};


#endif // EVDASHUSERS_H
