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

#ifndef BROWSERITEMS_H
#define BROWSERITEMS_H

#include <QAbstractListModel>
#include <QUuid>

class BrowserItem;

class BrowserItems: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    enum Roles {
        RoleId,
        RoleDisplayName,
        RoleDescription,
        RoleIcon,
        RoleThumbnail,
        RoleBrowsable,
        RoleExecutable,
        RoleDisabled,
        RoleActionTypeIds,

        RoleMediaIcon,
    };
    Q_ENUM(Roles)

    explicit BrowserItems(const QUuid &thingId, const QString &itemId, QObject *parent = nullptr);
    virtual ~BrowserItems() override;

    QUuid thingId() const;
    QString itemId() const;

    bool busy() const;

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    virtual void addBrowserItem(BrowserItem *browserItem);

    void removeItem(BrowserItem *browserItem);

    QList<BrowserItem*> list() const;
    void setBusy(bool busy);

    Q_INVOKABLE virtual BrowserItem* get(int index) const;
    Q_INVOKABLE virtual BrowserItem* getBrowserItem(const QString &itemId);

//    void clear();

signals:
    void countChanged();
    void busyChanged();

protected:
    bool m_busy = false;
    QList<BrowserItem*> m_list;

    QUuid m_thingId;
    QString m_itemId;
};

#endif // BROWSERITEMS_H
